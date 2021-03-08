import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_foreign/service/GraphqlService.dart';
import 'package:flutter_foreign/graphql/QueryMutation.dart';

class DetailRestPage extends StatefulWidget {
  DetailRestPage();
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<DetailRestPage> {
  TextEditingController comentController = TextEditingController();

  TextEditingController titleController = TextEditingController();
  TextEditingController contentsController = TextEditingController();

  String _restId;
  String _userName;
  String _userIdx;
  String _address;

  VoidCallback refetchQuery;
  static List<LazyCacheMap> rest;
  static List<LazyCacheMap> comm;

  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    _userIdx = GraphqlService.getIdx();
    _userName = GraphqlService.getName();
    setState(() {});
  }

  Future<int> createComm(String comment, num rating) async {
    var result = await GraphqlService.futureMutation(
        QueryMutation.createComm(comment, _userIdx, _restId, rating));
    print(result.data['createComm']["resultCount"]);
    return result.data['createComm']["resultCount"];
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context).settings.arguments;

    _restId = args['res_idx'];

    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Query(
                options: QueryOptions(
                  documentNode: gql(QueryMutation.getRest(_restId)),
                ),
                builder: (QueryResult result,
                    {FetchMore fetchMore, VoidCallback refetch}) {
                  refetchQuery = refetch;
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }
                  if (result.loading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Text("loading ...."),
                        ],
                      ),
                    );
                  }
                  rest = (result.data['getRest'] as List<dynamic>)
                      .cast<LazyCacheMap>();
                  _address = rest[0]['res_address'];

                  return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: ListTile(
                                  title: Text(rest[0]['res_name']),
                                  subtitle: Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber),
                                      Text(rest[0]['avgs'].toString())
                                    ],
                                  ),
                                  trailing: RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 30,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                      createCommDialog(rating);
                                    },
                                  ))),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                        child: Row(
                          children: [
                            Icon(Icons.place),
                            Flexible(
                                child: Text(rest[0]['res_address'],
                                    overflow: TextOverflow.clip))
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
              comment()
            ],
          ),
        )));
  }

  void createCommDialog(num rating) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text("Write Comment"),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  RatingBarIndicator(
                    rating: rating,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 30,
                    direction: Axis.horizontal,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Comments"),
                    controller: contentsController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    if (contentsController.text.isNotEmpty) {
                      await createComm(contentsController.text, rating)
                          .then((value) => {
                                if (value == 1)
                                  {
                                    Fluttertoast.showToast(
                                        msg: "Inserted Comment!!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0)
                                  }
                                else if (value == null)
                                  {
                                    Fluttertoast.showToast(
                                        msg: "Didn't insert comment!!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0)
                                  }
                              });

                      Navigator.pushNamed(context, '/detailRest',
                          arguments: <String, String>{'res_idx': _restId});
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please write a comment",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  child: Text("Save")),
              TextButton(
                  onPressed: () {
                    titleController.clear();
                    contentsController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
            ]);
      },
    );
  }

  Widget comment() {
    return Query(
        options: QueryOptions(
          documentNode: gql(QueryMutation.getComms(_restId)),
        ),
        builder: (QueryResult result,
            {FetchMore fetchMore, VoidCallback refetch}) {
          refetchQuery = refetch;
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          if (result.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text("No comments"),
                ],
              ),
            );
          }
          comm =
              (result.data['getComms'] as List<dynamic>).cast<LazyCacheMap>();
          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: comm.length,
              itemBuilder: (context, index) {
                dynamic responseData = comm[index];
                var writer = responseData['user_name'];
                var comment = responseData['com_content'];
                var score = responseData['com_score'];

                return _userIdx == writer
                    ? ListTile(
                        title: Text("$comment"),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text("$score  |  $writer")
                          ],
                        ),
                      )
                    : ListTile(
                        title: Text("$comment"),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text("$score  |  $writer")
                          ],
                        ),
                      );
              });
        });
  }
  // Widget button() {
  //   if (post[0]["No"] == _userNo) {
  //     return ButtonBar(mainAxisSize: MainAxisSize.min, children: <Widget>[
  //       RaisedButton(
  //           color: Color.fromRGBO(39, 50, 56, 1.0),
  //           child: Text(
  //             "수정",
  //             style: TextStyle(
  //               color: Colors.white,
  //             ),
  //           ),
  //           onPressed: () {
  //             _updatePostDialog(post[0]);
  //           }),
  //       RaisedButton(
  //           color: Colors.grey,
  //           child: Text("삭제"),
  //           onPressed: () {
  //             _deletePostDialog(post[0]);
  //           }),
  //     ]);
  //   } else {
  //     return null;
  //   }
  // }

}
