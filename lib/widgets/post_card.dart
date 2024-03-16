import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modernsocialapp/models/user.dart' as model;
import 'package:intl/intl.dart';
import 'package:modernsocialapp/providers/user_provider.dart';
import 'package:modernsocialapp/resources/firestore_methods.dart';
import 'package:modernsocialapp/screens/comments_screen.dart';
import 'package:modernsocialapp/screens/profile_screen.dart';
import 'package:modernsocialapp/utils/beautiful_divider.dart';
import 'package:modernsocialapp/utils/colors.dart';
import 'package:modernsocialapp/utils/global_variable.dart';
import 'package:modernsocialapp/utils/utils.dart';
import 'package:modernsocialapp/widgets/like_animation.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap; // Explicit type annotation added here
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      if (!mounted) return; // Check if the widget is still mounted
      commentLen = snap.docs.length;
      setState(() {});
    } catch (err) {
      if (!mounted) return; // Check if the widget is still mounted
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
      // If needed, you can return some value or success message here
    } catch (err) {
      // Rethrow the error to be handled where the function is called
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).getUser;

    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          const BeautifulDivider(true),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    uid: widget.snap['uid'].toString(),
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'].toString(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.snap['username'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5), // Add some space between username and icon
                          Icon(
                            Icons.check_circle_sharp,
                            color: (widget.snap['isVerified'].toString() == 'true') ? Colors.blue : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  widget.snap['uid'].toString() == user?.uid
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shrinkWrap: true,
                                      children: [
                                        'Delete',
                                      ]
                                          .map(
                                            (e) => InkWell(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () {
                                                  deletePost(
                                                    widget.snap['postId']
                                                        .toString(),
                                                  );
                                                  // remove the dialog box
                                                  Navigator.of(context).pop();
                                                }),
                                          )
                                          .toList()),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.more_vert),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              if(user != null) {
                FireStoreMethods().likePost(
                  widget.snap['postId'].toString(),
                  user.uid, // Now safely using user.uid without the null check operator
                  widget.snap['likes'],
                );
                setState(() {
                  isLikeAnimating = true;
                });
              } else {
                // Optionally, show a snackbar or a dialog asking the user to wait or log in.
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  // height: MediaQuery.of(context).size.height * 0.35,
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user?.uid),
                smallLike: true,
                child: IconButton(
                  icon: widget.snap['likes'].contains(user?.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                        ),
                  onPressed: () {
                    if(user != null) {
                      FireStoreMethods().likePost(
                        widget.snap['postId'].toString(),
                        user.uid, // Safe usage
                        widget.snap['likes'],
                      );
                    } else {
                      // Handle user being null - maybe show a snackbar?
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      postId: widget.snap['postId'].toString(),
                    ),
                  ),
                ),
              ),
              IconButton(
                  icon: const Icon(
                    Icons.send,
                  ),
                  onPressed: () {}),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    icon: const Icon(Icons.bookmark_border), onPressed: () {}),
              ))
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all $commentLen comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['postId'].toString(),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BeautifulDivider(false),
        ],
      ),
    );
  }
}
