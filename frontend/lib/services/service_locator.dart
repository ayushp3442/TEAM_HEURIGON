// lib/services/service_locator.dart
// Returns the real API services — mocks removed in Stage I2.
import 'auth_service.dart';
import 'subject_service.dart';
import 'tutor_service.dart';
import 'slot_service.dart';
import 'request_service.dart';
import 'chat_service.dart';
import 'api_auth_service.dart';
import 'api_subject_service.dart';
import 'api_tutor_service.dart';
import 'api_slot_service.dart';
import 'api_request_service.dart';
import 'api_chat_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static AuthService    get auth     => ApiAuthService();
  static SubjectService get subjects => ApiSubjectService();
  static TutorService   get tutors   => ApiTutorService();
  static SlotService    get slots    => ApiSlotService();
  static RequestService get requests => ApiRequestService();
  static ChatService    get chat     => ApiChatService();
}
