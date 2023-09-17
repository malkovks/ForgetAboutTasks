# ForgetAboutTasks Application
Little Introduction. This application using only imported frameworks and SDK's, it depended on internet connection because of authorization. Also current application has two changable localization: **Russian** and **English**. For Russian user's standart localization is **Russian**,for others - **English**. All texts, alerts and other information are localized.

### Stack of development:
1. UIKit, SwiftUI;
2. iOS 16+;
3. MVC(MVVM);
4. Realm;
5. UserDefaults for settings and Keychain for user's authorization data;
6. SnapKit;
7. Firebase and Google Authentication;
8. XCTests.

### This app based on:
- [SDK Firebase](https://github.com/firebase/);
- [FSCalendar](https://github.com/WenchaoD/FSCalendar);
- [SnapKit](https://github.com/SnapKit/SnapKit);
- [Realm](https://github.com/realm/realm-swift);

## Application intended for:
- Authorize user by creating account, login with previous created account or login with Google account;
- Creating, Editing events on current day in two variations:
  - Adding events in calendar with displaying counts of event on every day;
  - Adding events to basic table view with variations of sorting,searching events as it necessary.
- Creating contacts and duplicate them to system applications Contacts and also import contacts from the same application;
- Customization of self user interface, regulate access to systems elemenets, editing with current account.

## **Main Objectives:**
1. *User Authorization Module*
+ AuthenticationViewController:
  + View for choosing variations of how to login for user. User can login to previously created account, create account or authorize with Google.
+ LoginViewController:
  + View for enter with earlier created account or reset account if user forget password.
+ ResetViewController:
  + View for reset up password. After confirming server send to user mail to his mailbox with confirming about changing password and sets up new password.
+ CreateNewAccountViewController:
  + View for creating account. User enter email as login, first password and repeat it again and user's name. After that if internet connection is good, server's send answer that's account is created.


<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/d0fc23c8-02aa-47db-b5bf-e0e443d14fa9" width="300"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/2042ea02-6ca1-4b36-81b8-aea4aacee54a" width="300"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/95bc92fd-76ee-4d76-b77f-e45e5bd268fe" width="300">;

2. *Schedule Module*
+ ScheduleViewController:
  + View include calendar which display dots on day if on this day have any event or birthdays. Birthdays upload from contacts;
  + Search give access to find any event by name which ever was created;
  + List view present all event which has in current data base. Sorted by date.
+ CreateTaskViewController:
  + View display calendar week inline. At every days display table view with events which include at every row name, date and color of event;
  + Functions for editing chosen cells, delete and etc;
  + Display button at chosen day if has any birthdays. User can press to see who has any birthdays at current day.
+ DetailViewController:
  + View present event if user press before on cell. Show all details event. Give access to press on URL and open link if this value is not empty.
+ CreateEventScheduleViewController:
  + View has table view with 5 sections with different data. Even color of event, set image and other parameters.
+ EditEventScheduleViewController:
  + View same as CreateEventSchedule but give access to chosen model for editing.

<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/ff70e0c4-e2ab-4e29-867b-ddff2f0593fb" width="240"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/8f9d073f-3070-4c29-999b-87f03a789ac7" width="240"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/bb719f5a-b935-4490-9b4e-a2d2e3c278d9" width="240"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/409d143c-1732-4bd6-849a-37ba2512251e" width="240">

3. *All Tasks Module*
+ AllTasksViewController:
  + View display table view with lists of short events. Search using for searching events. Segmen controller give access to sort events.
+ AllTasksDetailViewController:
  + View display info about event with possibility to delete event, copy info from chosen row.
+ CreateTasksViewController:
  + View display table view with sections with fields of data and dates for filling.
+ EditTasksViewController:
  + View same as CreateTasksViewController, but work with chosen element of model and give access to change chosen value.

<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/86f23df1-2257-4e59-b408-609a667463a8" width="300">
<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/a104fbcd-d3db-4d82-960c-7ff2cf27ca82" width="300">
<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/b6e627ad-23a6-4334-ba9e-10d24bf3a5a9" width="300">

4. *Contacts Module*
+ ContactsViewController
  + View display table view with search bar for filtering contacts. Navigation item give access to user's systems Contacts and give access to import chosen contacts to our application. By long gesture on chosen table view row give possibilty to interact with. Even edit button give access to interact with table view models and edits them.
+ CreateContactViewController
  + View display custom view with adding image from library or creating image and table view with textfields for filling.
+ EditContactViewController
  + View same as CreateContactViewController but for edit chosen contact.


<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/d7284382-6faf-4bbd-990f-9a7ed2bfcd18" width="240"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/49c776c2-3788-469c-b416-1e7207f3299c" width="240"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/a341d4d7-a37c-4920-9108-f4266835803c" width="240"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/9ec2afd2-3663-457b-873e-7918aafdf4aa" width="240">

5. *User Profile Module*
+ UserProfileViewController
  + View display custom view with main information and image about user. Below is settings table view with huge perfomance for setting up application,password for entering in app,enabling animation,vibration, custom font and editing user's account.
 
<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/80355704-b5e3-4ff4-8c20-ba8ac1aabf16" width="300"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/ca6398b8-8d5e-4fce-9d1b-8af6c9af24f6" width="300"> <img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/d2efcd4c-6185-4a23-94fc-3bad353389fa" width="300">

6. *LockscreenWidget*
+ LockscreenWidget
  + Widget include current date and counts. By pressing open ScheduleViewController

<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/cee3fff2-5cb2-42ce-b40c-94acaf3710d2" width="300">


### Below example of some main functions which user can switch and edit
<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/5636f581-0f3d-4944-b63a-f0f07633a2cb" width="300">
<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/0959b978-d482-41a7-a7b9-3bf0497c585e" width="300">
<img src="https://github.com/kokmalkok/ForgetAboutTasks/assets/70747233/eac7d11b-1e06-4dbd-96ff-f08ce329bd5e" width="300">

### Personal resolved tasks in App:
* [X] Start work with Firebase Auth, Analytics, Crashlytics;
* [X] Using combine for some different tasks;
* [X] Using module tests for testing some business logic methods and class methods;
* [X] Test work with UIColorPickerViewController;
* [X] Test sharing function of table view in snapshot or .pdf variations;
* [X] Huge work with extensions, MVVM pattern and other helpful tools for development;
* [X] Code review and comments for all important functions and class;
* [X] Work with different target in one project. Combining Swift and SwiftUI;
* [X] Success work with Realm Database;
* [X] Creating custom TabBarController with animation;
* [X] Huge implementation of animation and work with them;
* [X] Work with versions and .git versions;
* [X] Added full localization of application and it event changable if user want it;
* [X] Work with Haptics on iPhone when user make some action with application. It edited if user need to switch vibration;
* [X] Work with Keychain manager for save storing email and password;
* [X] Full autolayout with SnapKit only;
* [X] Completed work with SystemConfiguration for checking internet connection;
* [X] Work with WidgetKit and display number of events on current day in widget.

### This project is non-commercial product. All rights reserved.
