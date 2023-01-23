import 'dart:developer';

import 'package:gallery/data/person.dart';

import '../auth.dart';

final campusAppsPortalInstance = CampusAppsPortal()
  ..setJWTSub('jwt-sub-id123')
  ..setUserPerson(
      Person(id: 2, jwt_sub_id: 'jwt-sub-id123', preferred_name: 'Nimal'));

class CampusAppsPortal {
  List<Person>? persons = [];
  bool precondisionsSubmitted = false;
  bool applicationSubmitted = false;
  final String schoolName = 'Bandaragama';
  int vacancyId = 1; // todo - this needs to be fetched and set from the server
  Person userPerson = Person();
  String? user_jwt_sub;
  String? user_jwt_email;
  CampusAppsPortalAuth? auth;
  bool signedIn = false;

  void setSignedIn(bool value) {
    signedIn = value;
  }

  bool getSignedIn() {
    return signedIn;
  }

  void setAuth(CampusAppsPortalAuth auth) {
    this.auth = auth;
  }

  Future<bool> getAuthSignedIn() async {
    final signedIn = await auth!.getSignedIn();
    return signedIn;
  }

  void setVacancyId(int id) {
    vacancyId = id;
  }

  int getVacancyId() {
    return vacancyId;
  }

  void setUserPerson(Person person) {
    userPerson = person;
  }

  Person getUserPerson() {
    return userPerson;
  }

  // void setApplication(Application? application) {
  //   this.application = application!;
  // }

  // Application getApplication() {
  //   return this.application;
  // }

  void setJWTSub(String? jwt_sub) {
    user_jwt_sub = jwt_sub;
  }

  String? getJWTSub() {
    return user_jwt_sub;
  }

  void setJWTEmail(String? jwt_email) {
    user_jwt_email = jwt_email;
  }

  String? getJWTEmail() {
    return user_jwt_email;
  }

  // void addEmployee(Employee employee) {
  //   allEmployees.add(employee);
  // }
  void setPrecondisionsSubmitted(bool value) {
    precondisionsSubmitted = value;
  }

  void setApplicationSubmitted(bool value) {
    applicationSubmitted = value;
  }

  bool getPrecondisionsSubmitted() {
    return precondisionsSubmitted;
  }

  bool getApplicationSubmitted() {
    return applicationSubmitted;
  }

  String getSchoolName() {
    return schoolName;
  }

  void setPersons(List<Person>? persons) {
    this.persons = persons;
  }

  void fetchPersonForUser() async {
    // check if user is in Avinya database person table as a student
    try {
      Person person = campusAppsPortalInstance.getUserPerson();
      if (person.jwt_sub_id == null ||
          person.jwt_sub_id != this.user_jwt_sub!) {
        person = await fetchPerson(this.user_jwt_sub!);
        this.userPerson = person;
        log('AdmissionSystem fetchPersonForUser: ' +
            person.toJson().toString());
      }
    } catch (e) {
      print(
          'AdmissionSystem fetchPersonForUser :: Error fetching person for user');
      print(e);
    }
  }

  void addPerson(Person person) {
    persons!.add(person);
  }
}
