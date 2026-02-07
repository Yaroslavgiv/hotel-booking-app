import 'package:equatable/equatable.dart';

abstract class WindowsOverviewEvent extends Equatable {
  const WindowsOverviewEvent();

  @override
  List<Object?> get props => [];
}

class WindowsOverviewRefreshRequested extends WindowsOverviewEvent {
  const WindowsOverviewRefreshRequested();
}

