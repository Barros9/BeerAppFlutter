import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/beer.dart';

void main() => runApp(const BeerApp());

class BeerApp extends StatelessWidget {
  const BeerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BeerHome(),
    );
  }
}

class BeerHome extends StatefulWidget {
  const BeerHome({Key? key}) : super(key: key);

  @override
  _BeerHomeState createState() => _BeerHomeState();
}

class _BeerHomeState extends State<BeerHome> {
  final ScrollController _scrollController = ScrollController();
  List<Beer> beers = [];
  int currentPage = 1;
  bool loading = false;
  bool allLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchBeers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        currentPage++;
        fetchBeers();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  fetchBeers() async {
    if (allLoaded) {
      return [];
    }
    setState(() {
      loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    final response = await http.Client()
        .get(Uri.parse('https://api.punkapi.com/v2/beers?page=$currentPage'));
    if (response.statusCode == 200) {
      final list = parseBeers(response.body);
      if (list.isNotEmpty) {
        beers.addAll(list);
      }
      setState(() {
        loading = false;
        allLoaded = list.isEmpty;
      });
    }
  }

  List<Beer> parseBeers(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Beer>((json) => Beer.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: colorPrimary,
        ),
        home: Scaffold(
            backgroundColor: colorPrimaryDark,
            appBar: AppBar(
                title: Text("BeerApp",
                    style: TextStyle(color: colorTextWhite, fontSize: 28.0)),
                centerTitle: true,
                backgroundColor: colorPrimaryDark),
            body: LayoutBuilder(builder: (context, constraints) {
              if (beers.isNotEmpty) {
                return Stack(children: [
                  ListView.separated(
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        if (index < beers.length) {
                          return _buildRow(beers[index], context);
                        } else {
                          return SizedBox(
                            width: constraints.maxWidth,
                            height: 80,
                          );
                        }
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(height: 1);
                      },
                      itemCount: beers.length + (loading ? 1 : 0)),
                  if (loading) ...[
                    Positioned(
                        left: 0,
                        bottom: 0,
                        child: SizedBox(
                            width: constraints.maxWidth,
                            height: 80,
                            child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colorAccent)))))
                  ]
                ]);
              } else {
                return Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                ));
              }
            })));
  }

  Widget _buildRow(Beer beer, BuildContext context) {
    return Card(
        color: colorPrimary,
        child: InkWell(
            onTap: () {
              showModalBottomSheet<dynamic>(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return _buildBottomSheet(beer, context);
                },
              );
            },
            child: Row(children: <Widget>[
              Container(
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxHeight: 100.0),
                child: beer.imageUrl != null
                    ? Image.network(beer.imageUrl!)
                    : Image.asset('assets/broken_image.png'),
                width: 40.0,
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(beer.name,
                              style: TextStyle(
                                  color: colorTextWhite, fontSize: 16.0)),
                          const SizedBox(height: 4),
                          Text(beer.tagline,
                              style: TextStyle(
                                  color: colorTextGrey, fontSize: 14.0)),
                          const SizedBox(height: 16),
                          Text(beer.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  color: colorTextGrey, fontSize: 14.0)),
                          const SizedBox(height: 8),
                          Text("MORE INFO",
                              style: TextStyle(
                                  color: colorAccent, fontSize: 14.0)),
                          // Text(beer.description, style: TextStyle(color: colorText)),
                        ],
                      )))
            ])));
  }

  Widget _buildBottomSheet(Beer beer, BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: colorPrimaryDark,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0))),
        child: Row(children: <Widget>[
          Container(
            margin:
                const EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 8),
            child: beer.imageUrl != null
                ? Image.network(beer.imageUrl!)
                : Image.asset('assets/broken_image.png'),
            width: 40.0,
            height: 100.0,
          ),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 24, bottom: 24, left: 8, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(beer.name,
                          style: TextStyle(
                              color: colorTextWhite,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(beer.tagline,
                          style:
                              TextStyle(color: colorTextGrey, fontSize: 16.0)),
                      const SizedBox(height: 16),
                      Text(beer.description,
                          style:
                              TextStyle(color: colorTextGrey, fontSize: 14.0)),
                      const SizedBox(height: 8),
                      Text("MORE INFO", style: TextStyle(color: colorAccent)),
                      // Text(beer.description, style: TextStyle(color: colorText)),
                    ],
                  )))
        ]));
  }
}

MaterialColor colorPrimary = MaterialColor(0xFF0B181D, color);
MaterialColor colorPrimaryDark = MaterialColor(0xFF1A262C, color);
MaterialColor colorAccent = MaterialColor(0xFFFCAF32, color);
MaterialColor colorTextWhite = MaterialColor(0xFFFFFFFF, color);
MaterialColor colorTextGrey = MaterialColor(0xFFA3A8AB, color);
Map<int, Color> color = {
  50: const Color.fromRGBO(4, 131, 184, .1),
  100: const Color.fromRGBO(4, 131, 184, .2),
  200: const Color.fromRGBO(4, 131, 184, .3),
  300: const Color.fromRGBO(4, 131, 184, .4),
  400: const Color.fromRGBO(4, 131, 184, .5),
  500: const Color.fromRGBO(4, 131, 184, .6),
  600: const Color.fromRGBO(4, 131, 184, .7),
  700: const Color.fromRGBO(4, 131, 184, .8),
  800: const Color.fromRGBO(4, 131, 184, .9),
  900: const Color.fromRGBO(4, 131, 184, 1),
};
