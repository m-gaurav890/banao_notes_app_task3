import 'package:banao_notes_app_task3/bloc/notes/notes_bloc.dart';
import 'package:banao_notes_app_task3/bloc/notes/notes_event.dart';
import 'package:banao_notes_app_task3/screen/search_page_screen.dart';
import 'package:banao_notes_app_task3/screen/side_menu_bar_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/note_model.dart';
import '../services/login_info.dart';
import '../services/note_db.dart';
import '../utilities/color.dart';
import 'create_note_view.dart';
import 'note_view_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String? imageUrl;
  bool isLoading = true;
  List<Note> activeNotes = [];
  List<Note> archivedNotes = [];
  List<Note> pinNotes = [];
  bool isSync = false;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  //Insert
  Future createEntry(Note note) async {
    await NotesDatabase.instance.insertData(note);
  }

  //Read All

  Future getAllNotes() async {
    LocalDataSaver.getImg().then((value) {
      if (this.mounted) {
        imageUrl = value;
      }
    });
    final List<Note> allNotes = await NotesDatabase.instance.readAllNotes();
    setState(() {
      activeNotes = allNotes.where((note) => !note.isArchived).toList();
      archivedNotes = allNotes.where((note) => note.isArchived).toList();
    });
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  //Read Specific

  Future getOneNote(int id) async {
    await NotesDatabase.instance.readOneNotes(id);
  }

  //Update Note

  Future updateOneNote(Note note) async {
    await NotesDatabase.instance.updateNotes(note);
  }

  // Delete Note

  Future deleteNote(int index) async {
    context.read<NotesBloc>().add(DeleteNoteEvent(activeNotes[index].id!));
  }

  //Managing sync state
  Future<void> getSyncState() async {
    final bool? syncState = await LocalDataSaver.getSyncData();
    if (syncState != null) {
      setState(() {
        isSync = syncState;
      });
    }
  }

  //Updating Note List Ui when the note is going to the archive page and from archive page
  void updateNotesList(Note note) {
    setState(() {
      if (note.isArchived) {
        // Remove the note from the activeNotes list
        activeNotes.removeWhere((element) => element.id == note.id);
        // Add the note to the archivedNotes list
        archivedNotes.add(note);
      } else {
        // Remove the note from the archivedNotes list
        archivedNotes.removeWhere((element) => element.id == note.id);
        // Add the note to the activeNotes list
        activeNotes.add(note);
      }
    });
  }

  @override
  void initState() {
    getAllNotes();
    getSyncState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: CircularProgressIndicator(
                color: white,
              ),
            ),
          )
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateNoteView()));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: bgColor,
              elevation: 1,
              foregroundColor: white,
              child: const Icon(
                Icons.add,
                size: 40,
              ),
            ),
            endDrawerEnableOpenDragGesture: true,
            key: _drawerKey,
            drawer: const SideMenu(),
            backgroundColor: bgColor,
            body: RefreshIndicator(
              onRefresh: () => Future.delayed(Duration(seconds: 1)),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          //Search container
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3)
                            ],
                            borderRadius: BorderRadius.circular(10),
                            color: cardColor,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _drawerKey.currentState!.openDrawer();
                                    },
                                    child: Icon(
                                      Icons.menu,
                                      color: white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SearchPage()));
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 200,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Search Your Notes",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: white.withOpacity(0.5)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              //second Row
                              Container(
                                padding: const EdgeInsets.only(right: 5),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    CircleAvatar(
                                      onBackgroundImageError:
                                          (object, StackTrace) {
                                        print("ok");
                                      },
                                      radius: 19,
                                      backgroundImage: NetworkImage(
                                        imageUrl.toString(),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        noteListSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget noteListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            children: [
              Text(
                "All",
                style: TextStyle(
                    color: white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeNotes.length,
            shrinkWrap: true,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NoteViewState(note: activeNotes[index])));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: white.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeNotes[index].title,
                      style: TextStyle(
                          color: white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      activeNotes[index].content.length > 250
                          ? "${activeNotes[index].content.substring(0, 250)}....."
                          : activeNotes[index].content,
                      style: TextStyle(color: white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
