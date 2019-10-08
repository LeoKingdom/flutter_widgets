import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///ad by yun.ling on 2019/09/06 14:00
///custom toast,you can call like this
///1. Toast.toast(context,msg:"$your msg")
///2. Toast.toast(context,msg:"$your msg",position:ToastPosition.top|center|bottom),show center on the screen is default position

//Toast show position
enum ToastPostion {
  top,
  center,
  bottom,
}

class Toast {
  // toast show on the screen base on this widget
  static OverlayEntry _overlayEntry;

  // toast when showing
  static bool _showing = false;

  // reset the show time
  static DateTime _startedTime;

  // show content
  static String _msg;

  // toast show time
  static int _showTime;

  // background color
  static Color _bgColor;

  // text color
  static Color _textColor;

  // text size
  static double _textSize;

  // show position
  static ToastPostion _toastPosition;

  // left and right padding
  static double _pdHorizontal;

  // top and bottom padding
  static double _pdVertical;

  static void toast(
    BuildContext context, {
    //show msg
    String msg,
    //show time , unit millis
    int showTime = 1000,
    //bg color,default black
    Color bgColor = Colors.black,
    //text color,default white
    Color textColor = Colors.white,
    //text size, default 14
    double textSize = 14.0,
    //show position,default center
    ToastPostion position = ToastPostion.center,
    //text horizontal padding
    double pdHorizontal = 20.0,
    //text vertical padding
    double pdVertical = 10.0,
  }) async {
    assert(msg != null);
    _msg = msg;
    _startedTime = DateTime.now();
    _showTime = showTime;
    _bgColor = bgColor;
    _textColor = textColor;
    _textSize = textSize;
    _toastPosition = position;
    _pdHorizontal = pdHorizontal;
    _pdVertical = pdVertical;
    //获取OverlayState
    OverlayState overlayState = Overlay.of(context);
    _showing = true;
    if (_overlayEntry == null) {
      //OverlayEntry负责构建布局
      //通过OverlayEntry将构建的布局插入到整个布局的最上层
      _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
                //top值，可以改变这个值来改变toast在屏幕中的位置
                top: buildToastPosition(context),
                child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: AnimatedOpacity(
                        opacity: _showing ? 1.0 : 0.0, //目标透明度
                        duration: _showing
                            ? Duration(milliseconds: 100)
                            : Duration(milliseconds: 400),
                        child: _buildToastWidget(),
                      ),
                    )),
              ));
      //插入到整个布局的最上层
      overlayState.insert(_overlayEntry);
    } else {
      //重新绘制UI，类似setState
      _overlayEntry.markNeedsBuild();
    }
    // 等待时间
    await Future.delayed(Duration(milliseconds: _showTime));
    //2秒后 到底消失不消失
    if (DateTime.now().difference(_startedTime).inMilliseconds >= _showTime) {
      _showing = false;
      _overlayEntry.markNeedsBuild();
      await Future.delayed(Duration(milliseconds: 400));
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  //toast绘制
  static _buildToastWidget() {
    return Center(
      child: Card(
        color: _bgColor,
        shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: _pdHorizontal, vertical: _pdVertical),
          child: Text(
            _msg,
            style: TextStyle(
              fontSize: _textSize,
              color: _textColor,
            ),
          ),
        ),
      ),
    );
  }

//  build the toast show position
  static buildToastPosition(context) {
    var backResult;
    if (_toastPosition == ToastPostion.top) {
      backResult = MediaQuery.of(context).size.height * 1 / 4;
    } else if (_toastPosition == ToastPostion.center) {
      backResult = MediaQuery.of(context).size.height * 2 / 5;
    } else {
      backResult = MediaQuery.of(context).size.height * 3 / 4;
    }
    return backResult;
  }
}
