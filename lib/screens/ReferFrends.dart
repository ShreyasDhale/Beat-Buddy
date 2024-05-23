import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactListScreen extends StatefulWidget {
  // final List<Contact> contacts;
  const ContactListScreen({super.key});

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  Iterable<Contact> contacts = [];
  bool dial = false;
  bool isSearching = false;
  bool inviteVisiblity = false;
  String link = "";
  String phoneNumber = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getlinks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getlinks() async {
    if (await Permission.contacts.request().isGranted) {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection("Download_Links")
          .doc("Beat_Buddy")
          .get();
      var data = snap.data() as Map<String, dynamic>;
      link = data['App'];
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
      try {
        Iterable<Contact> contact = await ContactsService.getContacts(
                withThumbnails: false, photoHighResolution: false)
            .whenComplete(() {
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
        });
        if (mounted) {
          setState(() {
            contacts = contact;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    } else {
      print('Permission denied');
    }
  }

  void toggleDialer() {
    if (mounted) {
      setState(() {
        dial = !dial;
      });
    }
  }

  void changeVisiblity(String value) {
    if (value.length == 10) {
      setState(() {
        inviteVisiblity = true;
        phoneNumber = value;
      });
    } else {
      setState(() {
        inviteVisiblity = false;
      });
    }
  }

  void filterContacts(String value) {
    Iterable<Contact> filteredContacts = contacts.where((contact) =>
        contact.displayName?.toLowerCase().contains(value.toLowerCase()) ??
        false);

    if (mounted) {
      if (value.isEmpty) {
        getlinks();
      }
    }
    if (mounted) {
      setState(() {
        contacts = filteredContacts.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.deepPurple.shade800.withOpacity(0.5),
          Colors.deepPurple.shade200.withOpacity(0.5)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: _buildContactList());
  }

  Widget _buildContactList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: getlinks,
                    icon: const Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Refresh",
                    style: GoogleFonts.poppins(color: Colors.white),
                  )
                ],
              ),
              Text(
                "Contacts",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.white),
              ),
              Column(
                children: [
                  IconButton(
                      onPressed: toggleDialer,
                      icon: const Icon(
                        Icons.dialpad,
                        color: Colors.white,
                      )),
                  Text(" New ", style: GoogleFonts.poppins(color: Colors.white))
                ],
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          dial
              ? Column(
                  children: [
                    TextFormField(
                      style: GoogleFonts.poppins(color: Colors.black),
                      keyboardType: TextInputType.phone,
                      onChanged: changeVisiblity,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Text(
                              "(+91)",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey),
                            ),
                          ),
                          suffixIcon: inviteVisiblity
                              ? TextButton(
                                  onPressed: () =>
                                      launchMessagingApp(phoneNumber),
                                  child: const Text("invite"))
                              : null,
                          hintText: "Enter Phone Number",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )
              : const SizedBox(),
          TextFormField(
            style: GoogleFonts.poppins(color: Colors.black),
            onChanged: filterContacts,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                hintText: "Search...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.white,
                  ))
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = contacts.elementAt(index);
                      if (contact.phones!.isNotEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            textColor: Colors.white,
                            leading: CircleAvatar(
                                backgroundImage: const NetworkImage(
                                    "https://cdn0.iconfinder.com/data/icons/mix1-1/200/Untitled-1-512.png"),
                                foregroundImage: contact.avatar!.isNotEmpty
                                    ? MemoryImage(contact.avatar!)
                                    : null),
                            title: contact.displayName != null
                                ? Text(contact.displayName!)
                                : null,
                            subtitle: Text(
                                contact.phones!.isNotEmpty
                                    ? contact.phones!.first.value!
                                    : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white)),
                            trailing: contact.phones!.isNotEmpty
                                ? ElevatedButton(
                                    onPressed: () => launchMessagingApp(
                                        contact.phones!.first.value!),
                                    child: const Text("INVIT"))
                                : null,
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void launchMessagingApp(String phoneNumber) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': 'Download My App Using This Link : $link'},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle error
      print('Could not launch messaging app');
    }
  }
}
