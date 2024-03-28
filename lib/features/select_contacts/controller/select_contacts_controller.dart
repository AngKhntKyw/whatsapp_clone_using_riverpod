import 'package:flutter/widgets.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/select_contacts/repository/select_contacts_repositories.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactsRepository = ref.watch(selectContactsRepositoryProvider);
  return selectContactsRepository.getContacts();
});

final selectContactControllerProvider = Provider((ref) {
  final selectContactsRepository = ref.watch(selectContactsRepositoryProvider);
  return SelectContactController(
      ref: ref, selectContactsRepository: selectContactsRepository);
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactsRepository selectContactsRepository;

  SelectContactController(
      {required this.ref, required this.selectContactsRepository});

  void selectContact(Contact selectedContact, BuildContext context) {
    selectContactsRepository.selectContact(selectedContact, context);
  }
}
