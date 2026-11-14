// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'LokaNusantara';

  @override
  String get language => '语言';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get followSystem => '跟随设备语言';

  @override
  String get contentLanguageNote => '来自服务器的地点名称、介绍和活动信息仍以印尼语显示。';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRetry => '重试';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

  @override
  String get commonSeeAll => '查看全部';

  @override
  String get errorNetwork => '网络连接失败';

  @override
  String get errorNotFound => '未找到数据';

  @override
  String get errorUnauthorized => '无访问权限';

  @override
  String get errorValidation => '输入有误';

  @override
  String get errorServer => '服务器出错了';

  @override
  String get errorUnknown => '出错了';

  @override
  String get catTradisi => '传统';

  @override
  String get catPura => '印度教神庙';

  @override
  String get catMasjid => '清真寺';

  @override
  String get catGereja => '教堂';

  @override
  String get catVihara => '佛寺';

  @override
  String get catKlenteng => '华人庙宇';

  @override
  String get catKuliner => '美食';

  @override
  String get catOther => '其他';

  @override
  String get etqGeneral1 => '衣着得体，保持安静。';

  @override
  String get etqGeneral2 => '拍摄当地居民或传统活动前请先征得同意。';

  @override
  String get etqGeneral3 => '遵守当地管理人员的规定和指引。';

  @override
  String get etqTradisi1 => '拍摄居民、房屋或传统仪式前请先征得同意。';

  @override
  String get etqTradisi2 => '遵守传统村落的规定和当地向导的指引。';

  @override
  String get etqTradisi3 => '不要触碰或跨过神圣物品和供品。';

  @override
  String get etqTradisi4 => '衣着得体；部分区域要求穿卡门（纱笼）并系腰带。';

  @override
  String get etqTradisi5 => '门票和捐款用于保护传统文化，条件允许时请聘请当地向导。';

  @override
  String get etqPura1 => '请穿卡门（纱笼）并在腰间系上腰带，通常可在入口处借用。';

  @override
  String get etqPura2 => '经期女性不得进入神圣区域。';

  @override
  String get etqPura3 => '不要攀爬、坐在或倚靠神圣建筑。';

  @override
  String get etqPura4 => '不要从正在祈祷的人面前走过。';

  @override
  String get etqPura5 => '注意不要踩到路上和庙院里的供品（Canang）。';

  @override
  String get etqMasjid1 => '穿着端庄、遮盖身体；女性需戴头巾。';

  @override
  String get etqMasjid2 => '进入礼拜区前请脱鞋。';

  @override
  String get etqMasjid3 => '除非前来礼拜，请避开集体礼拜时间参观。';

  @override
  String get etqMasjid4 => '保持安静，不要从正在礼拜的人面前经过。';

  @override
  String get etqGereja1 => '衣着得体，遮住肩膀和膝盖。';

  @override
  String get etqGereja2 => '保持安静，尤其是在弥撒或礼拜期间。';

  @override
  String get etqGereja3 => '礼拜期间拍摄内部前请先征得同意。';

  @override
  String get etqVihara1 => '衣着得体，遮住肩膀和膝盖。';

  @override
  String get etqVihara2 => '进入佛殿（Dhammasala）前请脱鞋。';

  @override
  String get etqVihara3 => '不要触摸佛像，也不要背对佛像拍照。';

  @override
  String get etqVihara4 => '在冥想区保持安静。';

  @override
  String get etqKlenteng1 => '衣着得体，保持安静。';

  @override
  String get etqKlenteng2 => '不要触碰祭坛、神像和祭祀用品。';

  @override
  String get etqKlenteng3 => '拍摄正在祈祷的人前请先征得同意。';

  @override
  String get etqKlenteng4 => '春节和元宵节（Cap Go Meh）人非常多，请尽早前往。';

  @override
  String get etqKuliner1 => '许多传统小吃店（warung）一早开门，卖完即关门。';

  @override
  String get etqKuliner2 => '部分巴厘岛菜肴含猪肉；如需清真食品请先询问。';

  @override
  String get etqKuliner3 => 'Sambal matah 和 betutu 相当辣，可按口味要求辣度。';

  @override
  String get etqKuliner4 => '请备好现金，并非所有小吃店都支持无现金支付。';

  @override
  String get dateToday => '今天';

  @override
  String get dateOngoing => '进行中';

  @override
  String get datePast => '已结束';

  @override
  String get dateTomorrow => '明天';

  @override
  String dateInDays(int count) {
    return '$count天后';
  }

  @override
  String dateInWeeks(int count) {
    return '$count周后';
  }

  @override
  String dateInMonths(int count) {
    return '$count个月后';
  }

  @override
  String get homeDestinations => '目的地';

  @override
  String homeSeeAllCount(int count) {
    return '查看全部$count个目的地';
  }

  @override
  String get homeAllDestinations => '全部目的地';

  @override
  String get homeSearchHint => '搜索目的地或地区...';

  @override
  String homeDestinationCount(int count) {
    return '$count个目的地';
  }

  @override
  String get homeNoMatch => '没有符合条件的目的地。';

  @override
  String get homeTagline => '探索巴厘岛的传统、宗教场所和特色美食';

  @override
  String get homeCategoryAll => '全部';

  @override
  String get homeNotFound => '未找到目的地';

  @override
  String get mapRouteUnavailableTitle => '暂无路线';

  @override
  String get mapRouteUnavailableBody => '未找到该出行方式的路线。';

  @override
  String get mapRouteFailedTitle => '失败';

  @override
  String get mapRouteFailedBody => '无法获取路线，请检查网络连接。';

  @override
  String get mapClose => '关闭地图';

  @override
  String get mapMyLocation => '我的位置';

  @override
  String get mapReload => '刷新';

  @override
  String get mapZoomIn => '放大';

  @override
  String get mapZoomOut => '缩小';

  @override
  String get mapPreparing => '正在准备地图';

  @override
  String get mapLoadingNearby => '正在加载附近的目的地';

  @override
  String mapTrailSummary(int count, int km) {
    return '$count个停靠点，约$km公里';
  }

  @override
  String get mapCloseTrail => '关闭路线';

  @override
  String get shellHome => '首页';

  @override
  String get shellSaved => '已收藏';

  @override
  String get shellAgenda => '活动';

  @override
  String get shellProfile => '我的';

  @override
  String get shellOpenMap => '打开地图';

  @override
  String get shellMap => '地图';

  @override
  String get splashTagline => '探索努山塔拉的传统';

  @override
  String get notifTitle => '通知';

  @override
  String notifWindow(int days) {
    return '未来$days天的文化活动';
  }

  @override
  String get notifEstimatedDate => '预计日期，可能会变动';

  @override
  String get notifEmptyTitle => '暂无通知';

  @override
  String notifEmptyBody(int days) {
    return '未来$days天内举行的文化活动将显示在这里。';
  }

  @override
  String get trailTitle => '故事路线';

  @override
  String trailStopCount(int count) {
    return '$count个停靠点';
  }

  @override
  String trailAboutKm(int km) {
    return '约$km公里';
  }

  @override
  String get trailStory => '路线故事';

  @override
  String get trailStops => '停靠点';

  @override
  String get trailShowOnMap => '在地图上查看路线';

  @override
  String get searchPlaceholder => '搜索地点...';

  @override
  String get searchNotFound => '未找到地点';

  @override
  String get detailMakePlan => '制定游览计划';

  @override
  String get detailAskLoka => '向 Tanya Loka 询问这个地方';

  @override
  String get detailAbout => '简介';

  @override
  String get detailHistory => '历史';

  @override
  String get detailHistoryEmpty => '暂无这个地方的历史介绍。';

  @override
  String get detailEtiquette => '参观礼仪';

  @override
  String get detailAddress => '地址';

  @override
  String get detailReviews => '评价';

  @override
  String get detailReviewsEmpty => '还没有评价，来分享第一条吧。';

  @override
  String detailReviewCount(int count) {
    return '$count 条评价';
  }

  @override
  String get detailNotRated => '暂无评分';

  @override
  String get detailDistance => '距离';

  @override
  String get detailCategory => '类别';

  @override
  String get detailVisitor => '游客';

  @override
  String get detailRoute => '查看路线';

  @override
  String get detailModeCar => '驾车';

  @override
  String get detailModeWalk => '步行';

  @override
  String get detailModeBike => '骑行';

  @override
  String get detailRating => '评分';

  @override
  String get detailNoRating => '暂无评分';

  @override
  String get detailDescription => '介绍';

  @override
  String get detailLatestReviews => '最新评价';

  @override
  String get detailFullHistory => '完整历史与详情';

  @override
  String get detailReadMore => '阅读全文';

  @override
  String get planTitle => '游览计划';

  @override
  String get planDeleteTitle => '删除计划';

  @override
  String get planDeleteMessage => '此游览计划将从你的账户中删除。';

  @override
  String get planDelete => '删除';

  @override
  String planDeleteFailed(String error) {
    return '删除失败：$error';
  }

  @override
  String planPeopleCount(int count) {
    return '$count 人';
  }

  @override
  String planDaysCount(int count) {
    return '$count 天';
  }

  @override
  String planMeta(String people, String days, String budget) {
    return '$people  •  $days  •  预算 $budget';
  }

  @override
  String get planSummary => '概要';

  @override
  String get planCosts => '费用明细';

  @override
  String get planTotalEstimate => '预计总计';

  @override
  String get planSchedule => '行程';

  @override
  String planDay(int day) {
    return '第 $day 天';
  }

  @override
  String get planTips => '小贴士';

  @override
  String get planDisclaimer => '计划和费用由 AI 估算。出发前请再次确认价格、开放时间和仪式日程。';

  @override
  String get planSavedMessage => '计划已保存，可在“已收藏”的计划标签中查看。';

  @override
  String planSaveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get planSavedLabel => '计划已保存';

  @override
  String get planSaveButton => '保存计划';

  @override
  String get planWithinBudget => '在预算内';

  @override
  String get planOverBudget => '超出预算';

  @override
  String get planEstimatedTotal => '预计总计';

  @override
  String get planPerPerson => '人均';

  @override
  String get planBudgetLeft => '预算剩余';

  @override
  String get planShortfall => '预算缺口';

  @override
  String get planBuilding => '正在制定计划';

  @override
  String planBuildingBody(String people, String days, String budget) {
    return 'AI 正在按 $people、$days、预算 $budget 估算费用，通常需要几秒钟。';
  }

  @override
  String get planBudgetLabel => '团体总预算';

  @override
  String get planPeople => '人数';

  @override
  String get planDuration => '游览天数';

  @override
  String planPerPersonApprox(String amount) {
    return '人均约 $amount';
  }

  @override
  String get planNotesLabel => '备注（可选）';

  @override
  String get planNotesHint => '例如：带小孩、骑摩托车、需要清真餐';

  @override
  String get planCreate => '制定计划';

  @override
  String get planSheetDisclaimer => '计划和费用均为 AI 估算，实际价格可能不同。';

  @override
  String get planDecrease => '减少';

  @override
  String get planIncrease => '增加';

  @override
  String planErrBudget(String amount) {
    return '预算至少为 $amount';
  }

  @override
  String planErrPeople(int max) {
    return '人数须为 1 至 $max 人';
  }

  @override
  String planErrDays(int max) {
    return '游览天数须为 1 至 $max 天';
  }

  @override
  String planErrNotes(int max) {
    return '备注最多 $max 个字符';
  }

  @override
  String get audioTitle => '语音导览';

  @override
  String audioPart(int index, int total) {
    return '第 $index 段，共 $total 段';
  }

  @override
  String get audioListen => '收听这个地方的故事（印尼语）';

  @override
  String get audioStop => '停止';

  @override
  String get audioSpeed => '语速';

  @override
  String get audioSpeedSlow => '慢';

  @override
  String get audioSpeedNormal => '正常';

  @override
  String get audioSpeedFast => '快';

  @override
  String get audioNoVoice => '设备未安装印尼语语音，将使用默认语音朗读。请在文字转语音设置中安装。';

  @override
  String get reviewWrite => '写评价';

  @override
  String get reviewPickRating => '请选择评分';

  @override
  String get reviewVeryBad => '很差';

  @override
  String get reviewBad => '差';

  @override
  String get reviewOkay => '一般';

  @override
  String get reviewGood => '好';

  @override
  String get reviewVeryGood => '很好';

  @override
  String get reviewRating => '评分';

  @override
  String get reviewComment => '评论（可选）';

  @override
  String get reviewHint => '在这里分享你的体验...';

  @override
  String bookmarkSaved(String name) {
    return '已收藏 $name';
  }

  @override
  String bookmarkRemoved(String name) {
    return '已取消收藏 $name';
  }

  @override
  String bookmarkFailed(String error) {
    return '收藏失败：$error';
  }

  @override
  String get dialogOk => '确定';

  @override
  String get savedTitle => '已收藏';

  @override
  String savedSubtitle(int places, int plans) {
    return '$places 个目的地，$plans 个计划';
  }

  @override
  String get savedSubtitleSignedOut => '收藏内容保存在你的账号中';

  @override
  String get savedTabPlaces => '地点';

  @override
  String get savedTabPlans => '计划';

  @override
  String get savedPlacesSignInTitle => '登录后查看收藏';

  @override
  String get savedPlacesFailed => '收藏加载失败';

  @override
  String get savedPlacesEmpty => '还没有收藏的目的地';

  @override
  String get savedPlacesSignInBody => '收藏的目的地保存在你的账号中，换手机也不会丢失。';

  @override
  String savedPullToRetry(String error) {
    return '$error 下拉即可重试。';
  }

  @override
  String get savedPlacesEmptyBody => '在想去的目的地上点按收藏图标即可。';

  @override
  String get savedRemove => '取消收藏';

  @override
  String get savedPlansSignInTitle => '登录后查看计划';

  @override
  String get savedPlansFailed => '计划加载失败';

  @override
  String get savedPlansEmpty => '还没有保存的计划';

  @override
  String get savedPlansSignInBody => '保存的游览计划会存放在你的账号中。';

  @override
  String get savedPlansEmptyBody => '打开一个地点，生成游览计划，然后点按“保存计划”。';

  @override
  String savedPlanMeta(int people, int days, String total) {
    return '$people 人  •  $days 天  •  $total';
  }

  @override
  String get savedWithinBudget => '在预算内';

  @override
  String get savedOverBudget => '超出预算';

  @override
  String get savedExploreHome => '去首页逛逛';

  @override
  String get savedSignInPlaceRequired => '请先登录再收藏目的地';

  @override
  String get savedSignInPlanRequired => '请先登录再保存计划';

  @override
  String get recentTitle => '浏览记录';

  @override
  String get recentSubtitle => '最近浏览的目的地';

  @override
  String get recentEmptyTitle => '暂无浏览记录';

  @override
  String get recentEmptyBody => '你打开过的目的地会显示在这里。';

  @override
  String get recentClear => '清除记录';

  @override
  String get recentClearMessage => '所有目的地浏览记录都将被清除。';

  @override
  String get recentClearConfirm => '清除';

  @override
  String get profileGuestName => '游客';

  @override
  String get profileGuestEmail => '登录后即可写评价';

  @override
  String get profileRecent => '最近浏览';

  @override
  String get profileOpenMap => '打开地图';

  @override
  String get profileShowIntro => '查看应用介绍';

  @override
  String get profileAbout => '关于 LokaNusantara';

  @override
  String get profileAboutBody => '印尼文化地图：传统、宗教场所与特色美食，从巴厘岛开始。';

  @override
  String get profileIntroOnLaunch => '启动时显示介绍';

  @override
  String get profileIntroOnLaunchDone => '下次打开应用时会显示介绍';

  @override
  String get profileSignOut => '退出登录';

  @override
  String get profileSignOutMessage => '确定要退出登录吗？';

  @override
  String get profileSignOutConfirm => '退出';

  @override
  String get profilePhoto => '头像';

  @override
  String get profileAuthTitle => '保存并分享你的旅程';

  @override
  String get profileAuthBody => '使用 Google 登录即可收藏目的地并撰写评价。';

  @override
  String get profileReminders => '文化活动提醒';

  @override
  String get profileRemindersBlocked => '通知已被屏蔽，请在手机设置中允许。';

  @override
  String get profileRemindersHint => '活动前一天及当天提醒';

  @override
  String get authSignIn => '登录';

  @override
  String get authFailedTitle => '登录失败';

  @override
  String get authErrorConfig => 'Google 登录尚未配置';

  @override
  String get authErrorFailed => 'Google 登录失败';

  @override
  String get authLater => '以后再说';

  @override
  String get authTagline => '探索印尼各地的\n传统、宗教场所与故事';

  @override
  String get authTitle => '登录开始探索';

  @override
  String get authSubtitle => '使用 Google 账号一键登录，无需设置新密码。';

  @override
  String get authBenefitSaveTitle => '收藏喜欢的目的地';

  @override
  String get authBenefitSaveBody => '把想去的地方都收集起来。';

  @override
  String get authBenefitReviewTitle => '撰写评价';

  @override
  String get authBenefitReviewBody => '与其他旅行者分享你的体验。';

  @override
  String get authBenefitSyncTitle => '保存在账号中';

  @override
  String get authBenefitSyncBody => '换手机也不会丢失收藏。';

  @override
  String get authPrivacy => '我们只会使用你 Google 账号的姓名、邮箱和头像。';

  @override
  String get authContinueGoogle => '使用 Google 继续';

  @override
  String get onbWelcomeTitle => '欢迎使用 LokaNusantara';

  @override
  String get onbWelcomeBody => '掌中的印尼文化地图。在一个应用里发现传统、宗教场所和特色美食。';

  @override
  String get onbTraditionTitle => '传统与宗教场所';

  @override
  String get onbTraditionBody => '走访传统村落、印度教神庙、清真寺、教堂、佛寺和华人庙宇，了解它们的历史与参观礼仪。';

  @override
  String get onbCulinaryTitle => '印尼风味';

  @override
  String get onbCulinaryBody =>
      '在世代相传的小吃店品尝传奇美食，从烤乳猪（babi guling）到香料蒸鸡（ayam betutu）。';

  @override
  String get onbRouteTitle => '收藏并规划路线';

  @override
  String get onbRouteBody => '收藏喜欢的目的地，回看浏览记录，并直接获取前往路线。';

  @override
  String get onbSkip => '跳过';

  @override
  String get onbStart => '开始探索';

  @override
  String get tanyaSuggest1 => '加隆安节是什么？';

  @override
  String get tanyaSuggest2 => '进入印度教神庙有哪些礼仪？';

  @override
  String get tanyaSuggest3 => '巴厘岛最古老的穆斯林村落在哪里？';

  @override
  String get tanyaSuggest4 => '在吉安雅必尝的特色美食有哪些？';

  @override
  String get tanyaSuggest5 => '哪些传统村落保留着巴厘阿加（Bali Aga）传统？';

  @override
  String get tanyaSuggest6 => '最近有哪些仪式？';

  @override
  String tanyaAboutPlace(String name) {
    return '介绍一下$name：简要历史、值得一看的地方，以及参观礼仪。';
  }

  @override
  String get tanyaNewChat => '新对话';

  @override
  String get tanyaNewChatMessage => '当前对话将被清除。';

  @override
  String get tanyaNewChatConfirm => '重新开始';

  @override
  String get tanyaSubtitle => 'AI 文化向导';

  @override
  String get tanyaGreeting => 'Om Swastyastu!';

  @override
  String get tanyaIntro =>
      '我是你的文化向导 Loka。可以问我巴厘岛的传统、宗教场所、美食或仪式安排。我的回答来自 LokaNusantara 的数据。';

  @override
  String get tanyaTryAsking => '试着问问';

  @override
  String get tanyaTyping => 'Loka 正在寻找答案';

  @override
  String get tanyaHint => '问问巴厘岛文化...';

  @override
  String get tanyaDisclaimer => 'AI 的回答可能有误，重要信息请向当地核实。';

  @override
  String get agendaTitle => '传统与文化';

  @override
  String get agendaSubtitle => '巴厘岛的节日、仪式和庆典';

  @override
  String get agendaAll => '全部';

  @override
  String get agendaEmptyCategory => '该类别暂无活动。';

  @override
  String get agendaSoon => '即将开始';

  @override
  String get agendaEstimate => '预计';

  @override
  String get agendaEstimateNote => '此日期为预计日期。按农历或委员会决定的节日可能会变动，出行前请查看官方公告。';

  @override
  String get agendaViewOnMap => '在地图上查看';

  @override
  String get agendaLocationDetail => '地点详情';

  @override
  String reminderTomorrow(String name) {
    return '明天：$name';
  }

  @override
  String reminderToday(String name) {
    return '今天：$name';
  }

  @override
  String get reminderEstimate => '日期为预计，请查看当地公告。';

  @override
  String get reminderDefaultPlace => '巴厘岛文化活动。';

  @override
  String get reminderChannelName => '文化活动提醒';

  @override
  String get reminderChannelDescription => '在文化活动前一天和当天提醒你。';

  @override
  String get navFailed => '失败';

  @override
  String get navReviewSaveFailed => '评价保存失败';

  @override
  String get langNameId => '印尼语';

  @override
  String get langNameEn => '英语';

  @override
  String get langNameKo => '韩语';

  @override
  String get langNameJa => '日语';

  @override
  String get langNameZh => '中文';
}
