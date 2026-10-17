// Single place that returns mock or real service based on dev_flags.dart.
// In Stage F11: set all flags to false, then delete dev_mocks/ and this file.
import '../dev_flags.dart';
import '../services/auth_service.dart';
import '../services/subject_service.dart';
import '../services/tutor_service.dart';
import '../services/slot_service.dart';
import '../services/request_service.dart';
import '../services/chat_service.dart';
import '../services/api_auth_service.dart';
import '../services/api_subject_service.dart';
import '../services/api_tutor_service.dart';
import '../services/api_slot_service.dart';
import '../services/api_request_service.dart';
import '../services/api_chat_service.dart';
import '../dev_mocks/mock_auth_service.dart';
import '../dev_mocks/mock_subject_service.dart';
import '../dev_mocks/mock_tutor_service.dart';
import '../dev_mocks/mock_slot_service.dart';
import '../dev_mocks/mock_request_service.dart';
import '../dev_mocks/mock_chat_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static AuthService     get auth     => useMockAuth     ? MockAuthService()     : ApiAuthService();
  static SubjectService  get subjects => useMockSubjects ? MockSubjectService()  : ApiSubjectService();
  static TutorService    get tutors   => useMockTutors   ? MockTutorService()    : ApiTutorService();
  static SlotService     get slots    => useMockSlots    ? MockSlotService()     : ApiSlotService();
  static RequestService  get requests => useMockRequests ? MockRequestService()  : ApiRequestService();
  static ChatService     get chat     => useMockChat     ? MockChatService()     : ApiChatService();
}
