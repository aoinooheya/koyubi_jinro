import 'package:flutter/material.dart';
import 'dart:async';

// Timer
class ClockTimer extends StatefulWidget{
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
    setState(() => {
      if (_time > 0){
        _time--
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Text(_time.toString());
  }
}