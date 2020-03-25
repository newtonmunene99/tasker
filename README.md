# Tasker 😃 <img src="https://github.com/newtonmunene99/tasker/blob/master/assets/images/logo.png" width="50px">


A simple todo app built with flutter.

| Screenshot                                                                       | Screenshot                                                                       | Screenshot                                                                       |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| <img src="https://github.com/newtonmunene99/tasker/blob/master/Screenshot1.png"> | <img src="https://github.com/newtonmunene99/tasker/blob/master/Screenshot2.png"> | <img src="https://github.com/newtonmunene99/tasker/blob/master/Screenshot3.png"> |
| <img src="https://github.com/newtonmunene99/tasker/blob/master/Screenshot4.png"> | <img src="https://github.com/newtonmunene99/tasker/blob/master/Screenshot5.png"> | <img src="https://github.com/newtonmunene99/tasker/blob/master/Screenshot6.png"> |
| ------------------------------                                                   | ------------------------------                                                   | ------------------------------                                                   |

## Getting Started

1. `flutter create -a kotlin --androidx --org com.yourdomainname .` if android/ios folders aren't present.
2. `flutter packages get`
3. `flutter run`

## Concepts

1. Provider for simple state management.
2. Stream builder for reactive data.
3. SQLite for persistence. 
4. Uses moor as an abstraction layer on top of SQFlite.

## Roadmap

- [x] Option to add due date
- [x] Option to tag user tasks
- [x] Option to edit and delete tasks
      - [x] Swipe to delete
      - [x] Long press to edit
- [ ] Scheduled local notifications for tasks tagged as Important and have a due date.
- [ ] Option to edit tags
- [ ] Publish to play store
- [ ] Redesign ui to custom design. (Not following Material/Cupertino)

## Icon/Logo

1. Replace `assets/images/logo.png` with your own.
2. Run `flutter pub pub run flutter_launcher_icons:main` to generate platform specific icons.

-----------------------------------------------------------------
A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
