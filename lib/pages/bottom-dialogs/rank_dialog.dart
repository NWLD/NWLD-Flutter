import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../util/game_utils.dart';
import '../../widgets/base_avatar.dart';
import 'bottom_dialog_container.dart';

class RankCell extends StatelessWidget {
  final int rankIndex;
  final String avatar;
  final String name;
  final String text;

  RankCell({
    @required this.rankIndex,
    @required this.avatar,
    @required this.name,
    @required this.text,
  });

  Color getRankIndexColor(int index) {
    switch (index) {
      case 1:
        return Color.fromRGBO(255, 218, 67, 1);
      case 2:
        return Color.fromRGBO(255, 77, 100, 1);
      case 3:
        return Color.fromRGBO(56, 139, 255, 1);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 672.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Color.fromRGBO(25, 29, 41, 1),
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.6),
                offset: Offset(0, 6),
              ),
            ],
            borderRadius: BorderRadius.all(
              const Radius.circular(8.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 110.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(56, 65, 92, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 35.w,
                    ),
                    child: Text(
                      rankIndex.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 60.w,
                        color: getRankIndexColor(rankIndex),
                      ),
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(
                  left: 24.w,
                  right: 15.w,
                ),
                alignment: Alignment.center,
                width: 65.w,
                height: 65.w,
                child: BaseAvatar(
                  avatar: avatar,
                  size: 70.w,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 8.w,
                ),
                alignment: Alignment.centerLeft,
                constraints: BoxConstraints(
                  maxWidth: 200.w,
                ),
                child: Text(
                  name ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConstant.h7,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: SizedBox(),
              ),
              Container(
                margin: EdgeInsets.only(
                  right: 24.w,
                  left: 8.w,
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: SizeConstant.h7,
                    color: Color.fromRGBO(255, 211, 125, 1),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.w),
      ],
    );
  }
}

class RankListView extends StatefulWidget {
  final Function itemBuilder;
  final Future service;
  final String cacheKey;

  RankListView({
    this.itemBuilder,
    this.service,
    this.cacheKey,
  });

  @override
  State<StatefulWidget> createState() {
    return RankListViewState();
  }
}

class RankListViewState extends State<RankListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //需要返回true

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List list = [];
    return ListView.builder(
      padding: EdgeInsets.only(top: 0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return widget.itemBuilder(item, index);
      },
    );
  }
}

class RankDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RankDialogState();
  }
}

class RankDialogState extends State<RankDialog>
    with SingleTickerProviderStateMixin, BaseLocalizationsStateMixin {
  TabController _tabController;
  PageController _pageController = PageController();
  int tabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("排行榜"),
      content: Container(
        padding: EdgeInsets.only(
          left: 18.w,
          right: 18.w,
        ),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(90, 236, 211, 1),
                border: Border.all(
                  color: Color.fromRGBO(0, 46, 105, 1),
                  width: 1,
                ),
                borderRadius: BorderRadius.all(
                  const Radius.circular(8.0),
                ),
              ),
              child: TabBar(
                labelPadding: EdgeInsets.all(0),
                indicatorWeight: 0.01,
                indicatorColor: Colors.transparent,
                labelColor: Colors.transparent,
                onTap: (index) {
                  _pageController.jumpToPage(index);
                  setState(() {
                    tabIndex = index;
                  });
                },
                controller: _tabController,
                isScrollable: false,
                tabs: buildTabs(),
              ),
            ),
            SizedBox(
              height: 18.w,
            ),
            Expanded(
                child: PageView(
              controller: _pageController,
              onPageChanged: (currentIndex) {
                setState(() {
                  tabIndex = currentIndex;
                  _tabController.index = tabIndex;
                });
              },
              // todo: 这里没有 keepAlive 住，每次切换 tab 都会去拉取三个榜单。需要 keepAlive 住 @feilong
              children: <Widget>[
                RankListView(
                  cacheKey: 'getRevenueRank',
                  itemBuilder: (item, index) {
                    return RankCell(
                      rankIndex: index + 1,
                      avatar: item['avatar_url'],
                      name: item['nickname'],
                      text: '',
                    );
                  },
                ),
                RankListView(
                  cacheKey: 'getFriendsRank',
                  itemBuilder: (item, index) {
                    return RankCell(
                      rankIndex: index + 1,
                      avatar: item['avatar_url'],
                      name: item['nickname'],
                      text: GameUtils.formatNumber(
                        item['friend_direct_count'],
                      ),
                    );
                  },
                ),
                RankListView(
                  cacheKey: 'getCoinRank',
                  itemBuilder: (item, index) {
                    return RankCell(
                      rankIndex: index + 1,
                      avatar: item['avatar_url'],
                      name: item['nickname'],
                      text: '',
                    );
                  },
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  List<Widget> buildTabs() {
    List<Widget> list = [];
    List<String> titles = [$t("收益"), $t("朋友"), $t("金币")];
    for (int index = 0; index < titles.length; index++) {
      list.add(
        Container(
          height: 80.w,
          constraints: BoxConstraints(minWidth: 128.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                titles[index],
                style: TextStyle(
                  fontSize: SizeConstant.h8,
                  color: index == tabIndex
                      ? Color.fromRGBO(25, 29, 41, 1)
                      : Color.fromRGBO(25, 29, 41, 0.7),
                ),
              ),
              // 底部选中标签
              Positioned(
                bottom: 0,
                child: Container(
                  width: 128.w,
                  height: 13.w,
                  decoration: BoxDecoration(
                    color: index == tabIndex
                        ? ColorConstant.title
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.w),
                      topRight: Radius.circular(10.w),
                    ),
                    border: Border.all(
                        color: index == tabIndex
                            ? Color(0xFF000000)
                            : Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return list;
  }
}
