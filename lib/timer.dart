import 'package:flutter/material.dart';
import 'dart:async';

// Timer
class ClockTimer extends StatefulWidget{
  const ClockTimer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState(){
    return _ClockTimerState();
  }
}

class _ClockTimerState extends State<ClockTimer>{
  int _time = 10;

  @override
  void initState(){
    super.initState();
    Timer.periodic(const Duration(seconds:1), _onTimer);
  }

  @override
  void _onTimer(Timer timer){
    if (_time > 0){
      setState(() => {
      _time--
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Text(_time.toString());
  }
}