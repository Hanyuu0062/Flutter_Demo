import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

typedef ListItemBuilder<T> = Widget Function(
    BuildContext context, int count, int index, T data);
typedef OnRefreshData<T> = Future<T> Function(int pageNum, int pageSize);
typedef OnLoadData<T> = Future<T> Function(int pageNum, int pageSize);
typedef OnDataUpdate<T> = void Function(T datas);

/// 分页加载 ListView
/// 根据每页加载数量与实际单次加载数量，自维护下拉加载更多操作：
/// 单次加载数量小于每页加载数量的话，禁用加载更多，只有重新下拉刷新，才能更新这个状态
///
/// 结合 EasyRefresh 实现下拉刷新及上拉加载更多，屏蔽 EasyRefresh 相关接口，这样有利于第三方解耦
/// 后续要自定义下拉和上拉UI时，要屏蔽 EasyRefresh 相关接口，不要强耦合
///
/// EasyRefresh接口文档：https://github.com/xuelongqy/flutter_easy_refresh/blob/v3/README_CN.md
///
class LoadListView<T> extends StatefulWidget {
  final int pageSize;
  final Widget? emptyWidget;
  final bool refreshOnStart;
  final bool canDropDown;
  final bool canPullUp;
  final OnRefreshData<List<T>?> onRefreshData;
  final OnLoadData<List<T>?> onLoadData;
  final ListItemBuilder<T> itemBuilder;
  final OnDataUpdate<List<T>>? onDataUpdate;
  final LoadListViewController? controller;

  /// [pageSize] 每页加载条目数，页数 pageNum 由 _LoadListViewState 维护
  /// [emptyWidget] 数据为空时的占位视图，靠上居中
  /// [refreshOnStart] 首次自动刷新
  /// [canDropDown] 是否可以下拉（刷新），默认true
  /// [canPullUp] 是否可以上拉（加载），默认true
  /// [itemBuilder] item视图构造器
  /// [onRefreshData] 下拉刷新数据，由使用者维护传入
  /// [onLoadData] 上拉加载更多数据，由使用者维护传入
  /// [onDataUpdate] 数据更新回调
  const LoadListView({
    Key? key,
    this.pageSize = 20,
    this.emptyWidget,
    this.refreshOnStart = false,
    this.canDropDown = true,
    this.canPullUp = true,
    required this.onRefreshData,
    required this.onLoadData,
    required this.itemBuilder,
    this.onDataUpdate,
    this.controller,
  }) : super(key: key);

  @override
  State<LoadListView<T>> createState() => _LoadListViewState<T>();
}

class _LoadListViewState<T> extends State<LoadListView<T>> {
  bool hasRefresh = false;
  List<T> dataList = [];
  int pageNum = 0;
  bool noMore = false;
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final ScrollController scrollController = ScrollController();

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._setOnListener(
      getTotalCount: () => dataList.length,
      callRefresh: (bool silent) {
        if (silent) {
          refreshDataSilently();
        } else {
          refreshData();
        }
      },
      removeItem: (index) {
        if (dataList.length < (index + 1)) {
          debugPrint('删除item失败，数组越界');
          return;
        }
        dataList.removeAt(index);
        widget.onDataUpdate?.call(dataList);
        setState(() {});
      },
    );
    if (widget.refreshOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        refreshDataSilently();
      });
    }
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      callRefreshOverOffset: 5,
      controller: refreshController,
      header: const MaterialHeader(),
      footer: const ClassicFooter(
        triggerOffset: 40,
        showMessage: false,
        iconDimension: 0,
        iconTheme: IconThemeData(size: 0),
        spacing: 0,
        processingText: '正在加载',
        noMoreText: '没有更多',
        textStyle: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onRefresh: widget.canDropDown ? refreshDataSilently : null,
      onLoad: widget.canPullUp ? loadData : null,
      child: (dataList.isEmpty && hasRefresh && (widget.emptyWidget != null))
          ? SizedBox(
        height: double.maxFinite,
        child: SingleChildScrollView(
          controller: scrollController,
          child: widget.emptyWidget!,
        ),
      )
          : ListView.builder(
        controller: scrollController,
        itemCount: dataList.length,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        itemBuilder: (BuildContext context, int index) {
          debugPrint('+++ LoadListView index:$index +++');
          return widget.itemBuilder(
              context, dataList.length, index, dataList[index]);
        },
      ),
    );
  }

  /// 刷新数据：展示下拉header
  Future<void> refreshData() async {
    refreshController.callRefresh();
  }

  /// 静默刷新数据：不展示下拉header，直接刷新数据
  Future<void> refreshDataSilently() async {
    debugPrint('+++ LoadListView refreshData +++');
    // 每次刷新就重置数据，然后加载第一页
    pageNum = 1;
    noMore = false;
    List<T> list = (await widget.onRefreshData(pageNum, widget.pageSize)) ?? [];
    if (!mounted) return;
    if (list.isEmpty) {
      pageNum = 0;
    }
    setState(() {
      hasRefresh = true;
      dataList = list;
      widget.onDataUpdate?.call(dataList);
    });
    // 下拉刷新加载的数据如果为空或者小于每页条目数，说明没有更多数据
    noMore = (list.length < widget.pageSize);
    refreshController.finishRefresh(IndicatorResult.success);

    /// 跳转到顶部：
    /// 用于解决下拉刷新数据为空时，采用[widget.emptyWidget]后，EasyRefresh下拉没有反应的问题
    if (list.isEmpty && (widget.emptyWidget != null)) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        scrollController.jumpTo(0.00001);
      });
    }
  }

  /// 下拉加载更多数据
  Future<void> loadData() async {
    if (noMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      debugPrint('+++ LoadListView 没有更多 +++');
      return;
    }
    debugPrint('+++ LoadListView loadData +++');
    pageNum += 1;
    List<T> list = (await widget.onLoadData(pageNum, widget.pageSize)) ?? [];
    if (!mounted) return;
    if (list.isEmpty) {
      pageNum -= 1;
    } else {
      setState(() {
        dataList.addAll(list);
        widget.onDataUpdate?.call(dataList);
      });
    }
    // 最后一次加载的数据如果为空或者小于每页条目数，说明没有更多数据
    noMore = (list.length < widget.pageSize);
    refreshController
        .finishLoad(noMore ? IndicatorResult.noMore : IndicatorResult.none);
  }
}

class LoadListViewController {
  void _setOnListener({
    required Function? getTotalCount,
    required Function(bool silent)? callRefresh,
    required void Function(int index)? removeItem,
  }) {
    _getItemCount = getTotalCount;
    _callRefresh = callRefresh;
    _removeItem = removeItem;
  }

  Function? _getItemCount;

  /// 获取当前数据总数
  int get itemCount {
    return _getItemCount?.call() ?? 0;
  }

  Function(bool silent)? _callRefresh;

  /// 触发下拉刷新
  /// [silent] 是否静默刷新，不展示转圈圈，默认展示转圈圈
  void callRefresh({bool silent = false}) {
    _callRefresh?.call(silent);
  }

  void Function(int index)? _removeItem;

  void removeItem(int index) {
    _removeItem?.call(index);
  }
}

