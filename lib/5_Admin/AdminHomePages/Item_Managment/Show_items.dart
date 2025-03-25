import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShowItemPage extends StatefulWidget {
  @override
  _ShowItemPageState createState() => _ShowItemPageState();
}

class _ShowItemPageState extends State<ShowItemPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ShowItemProvider>(context, listen: false).fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShowItemProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Items List")),
      body: provider.items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final item = provider.items[index];
          List<String> images = item['item_image'];  // Multiple images list

          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [//gjhgjg
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, imgIndex) {
                      return Image.network(images[imgIndex], fit: BoxFit.cover);
                    },
                  ),
                ),
                ListTile(
                  title: Text(item['item_name']),
                  subtitle: Text(item['item_description']),
                  trailing: Text("${item['sale_price']}Pkr"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
