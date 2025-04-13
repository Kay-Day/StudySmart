// import 'dart:async';
// import 'package:flutter/material.dart' hide State; // Import Flutter nhưng ẩn class State
// import 'package:flutter/material.dart' as flutter; // Import Flutter với prefix
// import 'package:mongo_dart/mongo_dart.dart';
// import '../../../constants/app_colors.dart';
// import '../../../constants/app_constants.dart';
// import '../../../data/models/subject.dart';
// import '../../../providers/study_session_provider.dart';
// import '../../../helpers/date_time_helper.dart';
// import '../../../widgets/custom_button.dart';
// import '../../../widgets/empty_state.dart';

// class StudyTimerWidget extends flutter.StatefulWidget {
//   final List<Subject> subjects;
//   final StudySessionProvider sessionProvider;
//   final ObjectId? userId;
  
//   const StudyTimerWidget({
//     Key? key,
//     required this.subjects,
//     required this.sessionProvider,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   flutter.State<StudyTimerWidget> createState() => _StudyTimerWidgetState();
// }

// class _StudyTimerWidgetState extends flutter.State<StudyTimerWidget> {
//   Subject? _selectedSubject;
//   Timer? _timer;
//   int _elapsedSeconds = 0;
//   String _timerDisplay = '00:00:00';
//   final TextEditingController _notesController = TextEditingController();
//   int _productivityRating = 3;
  
//   @override
//   void initState() {
//     super.initState();
//     // Nếu có phiên học đang diễn ra, khởi tạo lại bộ đếm
//     if (widget.sessionProvider.hasActiveSession) {
//       _startTimer();
      
//       // Tìm môn học đang học
//       if (widget.sessionProvider.activeSubjectId != null) {
//         for (var subject in widget.subjects) {
//           if (subject.id == widget.sessionProvider.activeSubjectId) {
//             _selectedSubject = subject;
//             break;
//           }
//         }
//       }
//     }
//   }
  
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _notesController.dispose();
//     super.dispose();
//   }
  
//   void _startTimer() {
//     final startTime = widget.sessionProvider.startTime ?? DateTime.now();
//     final now = DateTime.now();
//     _elapsedSeconds = now.difference(startTime).inSeconds;
    
//     _updateTimerDisplay();
    
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _elapsedSeconds++;
//         _updateTimerDisplay();
//       });
//     });
//   }
  
//   void _updateTimerDisplay() {
//     final hours = (_elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
//     final minutes = ((_elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
//     final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
//     _timerDisplay = '$hours:$minutes:$seconds';
//   }
  
//   void _startStudySession() {
//     if (_selectedSubject == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vui lòng chọn môn học trước khi bắt đầu'),
//           backgroundColor: AppColors.warning,
//         ),
//       );
//       return;
//     }
    
//     widget.sessionProvider.startSession(_selectedSubject!.id);
//     _startTimer();
//   }
  
//   Future<void> _endStudySession() async {
//     _timer?.cancel();
    
//     if (widget.userId == null) return;
    
//     // Hiển thị dialog đánh giá phiên học
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Kết thúc phiên học'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Đánh giá mức độ hiệu quả:'),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(5, (index) {
//                   return IconButton(
//                     icon: Icon(
//                       index < _productivityRating ? Icons.star : Icons.star_border,
//                       color: index < _productivityRating ? AppColors.warning : null,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _productivityRating = index + 1;
//                       });
//                     },
//                   );
//                 }),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _notesController,
//                 decoration: const InputDecoration(
//                   labelText: 'Ghi chú (không bắt buộc)',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Khôi phục timer
//               _startTimer();
//             },
//             child: const Text('Hủy'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.of(context).pop();
              
//               final success = await widget.sessionProvider.endSession(
//                 widget.userId!,
//                 _notesController.text.isEmpty ? null : _notesController.text,
//                 _productivityRating,
//               );
              
//               if (success) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Đã lưu phiên học thành công'),
//                     backgroundColor: AppColors.success,
//                   ),
//                 );
                
//                 // Reset
//                 setState(() {
//                   _elapsedSeconds = 0;
//                   _timerDisplay = '00:00:00';
//                   _notesController.clear();
//                   _productivityRating = 3;
//                 });
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(widget.sessionProvider.error ?? 'Không thể lưu phiên học'),
//                     backgroundColor: AppColors.error,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Lưu'),
//           ),
//         ],
//       ),
//     );
//   }
  
//   void _cancelStudySession() {
//     _timer?.cancel();
//     widget.sessionProvider.cancelSession();
    
//     setState(() {
//       _elapsedSeconds = 0;
//       _timerDisplay = '00:00:00';
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final isStudying = widget.sessionProvider.hasActiveSession;
    
//     if (widget.subjects.isEmpty) {
//       return const EmptyState(
//         title: 'Chưa có môn học nào',
//         message: 'Hãy thêm môn học để bắt đầu theo dõi thời gian học tập',
//         icon: Icons.book,
//       );
//     }
    
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!isStudying) ...[
//               // Chọn môn học
//               DropdownButtonFormField<Subject>(
//                 decoration: const InputDecoration(
//                   labelText: 'Chọn môn học',
//                   border: OutlineInputBorder(),
//                 ),
//                 value: _selectedSubject,
//                 items: widget.subjects.map((subject) {
//                   return DropdownMenuItem<Subject>(
//                     value: subject,
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 16,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: AppColors.fromHex(subject.color),
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(subject.name),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedSubject = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               // Nút bắt đầu
//               CustomButton(
//                 text: 'Bắt Đầu Học',
//                 icon: Icons.play_arrow,
//                 onPressed: _startStudySession,
//                 isFullWidth: true,
//               ),
//             ] else ...[
//               // Hiển thị môn học đang học
//               Row(
//                 children: [
//                   Container(
//                     width: 16,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       color: _selectedSubject != null
//                           ? AppColors.fromHex(_selectedSubject!.color)
//                           : AppColors.primary,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Đang học: ${_selectedSubject?.name ?? 'Môn học'}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               // Hiển thị thời gian
//               Center(
//                 child: Text(
//                   _timerDisplay,
//                   style: const TextStyle(
//                     fontSize: 48,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'monospace',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Nút kết thúc và hủy
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                       text: 'Kết Thúc',
//                       type: ButtonType.secondary,
//                       icon: Icons.stop,
//                       onPressed: _endStudySession,
//                       isFullWidth: true,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: CustomButton(
//                       text: 'Hủy',
//                       type: ButtonType.outline,
//                       icon: Icons.cancel,
//                       onPressed: _cancelStudySession,
//                       isFullWidth: true,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart' hide State; // Import Flutter but hide State class
import 'package:flutter/material.dart' as flutter; // Import Flutter with prefix
import 'package:mongo_dart/mongo_dart.dart' hide Center; // Import mongo_dart but hide Center class
import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../data/models/subject.dart';
import '../../../providers/study_session_provider.dart';
import '../../../helpers/date_time_helper.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';

class StudyTimerWidget extends flutter.StatefulWidget {
  final List<Subject> subjects;
  final StudySessionProvider sessionProvider;
  final ObjectId? userId;
  
  const StudyTimerWidget({
    Key? key,
    required this.subjects,
    required this.sessionProvider,
    required this.userId,
  }) : super(key: key);

  @override
  flutter.State<StudyTimerWidget> createState() => _StudyTimerWidgetState();
}

class _StudyTimerWidgetState extends flutter.State<StudyTimerWidget> {
  Subject? _selectedSubject;
  Timer? _timer;
  int _elapsedSeconds = 0;
  String _timerDisplay = '00:00:00';
  final TextEditingController _notesController = TextEditingController();
  int _productivityRating = 3;
  
  @override
  void initState() {
    super.initState();
    // If there's an active session, initialize the timer
    if (widget.sessionProvider.hasActiveSession) {
      _startTimer();
      
      // Find the current subject
      if (widget.sessionProvider.activeSubjectId != null) {
        for (var subject in widget.subjects) {
          if (subject.id == widget.sessionProvider.activeSubjectId) {
            _selectedSubject = subject;
            break;
          }
        }
      }
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }
  
  void _startTimer() {
    final startTime = widget.sessionProvider.startTime ?? DateTime.now();
    final now = DateTime.now();
    _elapsedSeconds = now.difference(startTime).inSeconds;
    
    _updateTimerDisplay();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        _updateTimerDisplay();
      });
    });
  }
  
  void _updateTimerDisplay() {
    final hours = (_elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    _timerDisplay = '$hours:$minutes:$seconds';
  }
  
  void _startStudySession() {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn môn học trước khi bắt đầu'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    widget.sessionProvider.startSession(_selectedSubject!.id);
    _startTimer();
  }
  
  Future<void> _endStudySession() async {
    _timer?.cancel();
    
    if (widget.userId == null) return;
    
    // Show session rating dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc phiên học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Đánh giá mức độ hiệu quả:'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _productivityRating ? Icons.star : Icons.star_border,
                      color: index < _productivityRating ? AppColors.warning : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _productivityRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (không bắt buộc)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Restore timer
              _startTimer();
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await widget.sessionProvider.endSession(
                widget.userId!,
                _notesController.text.isEmpty ? null : _notesController.text,
                _productivityRating,
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu phiên học thành công'),
                    backgroundColor: AppColors.success,
                  ),
                );
                
                // Reset
                setState(() {
                  _elapsedSeconds = 0;
                  _timerDisplay = '00:00:00';
                  _notesController.clear();
                  _productivityRating = 3;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.sessionProvider.error ?? 'Không thể lưu phiên học'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
  
  void _cancelStudySession() {
    _timer?.cancel();
    widget.sessionProvider.cancelSession();
    
    setState(() {
      _elapsedSeconds = 0;
      _timerDisplay = '00:00:00';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isStudying = widget.sessionProvider.hasActiveSession;
    
    if (widget.subjects.isEmpty) {
      return const EmptyState(
        title: 'Chưa có môn học nào',
        message: 'Hãy thêm môn học để bắt đầu theo dõi thời gian học tập',
        icon: Icons.book,
      );
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isStudying) ...[
              // Select subject
              DropdownButtonFormField<Subject>(
                decoration: const InputDecoration(
                  labelText: 'Chọn môn học',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSubject,
                items: widget.subjects.map((subject) {
                  return DropdownMenuItem<Subject>(
                    value: subject,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.fromHex(subject.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(subject.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Start button
              CustomButton(
                text: 'Bắt Đầu Học',
                icon: Icons.play_arrow,
                onPressed: _startStudySession,
                isFullWidth: true,
              ),
            ] else ...[
              // Show current subject
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _selectedSubject != null
                          ? AppColors.fromHex(_selectedSubject!.color)
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang học: ${_selectedSubject?.name ?? 'Môn học'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Display timer
              flutter.Center(
                child: Text(
                  _timerDisplay,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // End and cancel buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Kết Thúc',
                      type: ButtonType.secondary,
                      icon: Icons.stop,
                      onPressed: _endStudySession,
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: 'Hủy',
                      type: ButtonType.outline,
                      icon: Icons.cancel,
                      onPressed: _cancelStudySession,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}