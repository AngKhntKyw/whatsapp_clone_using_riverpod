import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/select_contacts/controller/select_contacts_controller.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const routeName = '/select-contacts';
  const SelectContactsScreen({super.key});

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contacts'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
        data: (contacts) {
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return InkWell(
                onTap: () {
                  contact.phones.isNotEmpty
                      ? selectContact(ref, contact, context)
                      : null;
                },
                // onTap: () => selectContact(ref, contact, context),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: contact.photo != null
                        ? MemoryImage(contact.photo!)
                        : null,
                    child:
                        contact.photo != null ? null : const Icon(Icons.person),
                  ),
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Scaffold(body: ErrorScreen(error: error.toString()));
        },
        loading: () {
          return const Scaffold(body: Loader());
        },
      ),
    );
  }
}
