import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:k6_app/models/product_models.dart';
import 'package:k6_app/models/seller_model.dart';
import 'package:k6_app/models/shop_model.dart';
import 'package:k6_app/screens/Seller/add_product_seller.dart';
import 'package:k6_app/utility/my_constant.dart';
import 'package:k6_app/utility/my_style.dart';

class ProductListSeller extends StatefulWidget {
  ProductListSeller({required this.sellerModel});
  final SellerModel sellerModel;
  @override
  _ProductListSellerState createState() => _ProductListSellerState();
}

class _ProductListSellerState extends State<ProductListSeller> {
  List<ProductModel> productModels = [];
  ShopModel? shopModel;
  bool? loadStatus = true;
  bool? status = true;
  SellerModel? sellerModel;
  String? idshop, idseller;
  @override
  void initState() {
    super.initState();
    sellerModel = widget.sellerModel;
    readDataShop();
    readProduct();
  }

  Future<Null> readDataShop() async {
    idseller = sellerModel?.idSeller;
    String url =
        '${MyConstant().domain}/projectk6/getSellerwhereSHOP.php?isAdd=true&id_seller=$idseller';
    Response response = await Dio().get(url);

    var result = json.decode(response.data);
    print('result = $result');

    if (result != null) {
      for (var map in result) {
        setState(() {
          shopModel = ShopModel.fromMap(map);
        });
      }
    } else {}
    print(shopModel?.nameshop);
  }

  Future<Null> readProduct() async {
    if (productModels.length != 0) {
      loadStatus = true;
      status = true;
      productModels.clear();
    }

    idshop = shopModel?.idShop;
    print('>>>>>>>$idshop');
    // String url =
    //     '${MyConstant().domain}/projectk6/getproductWhereidShop.php?isAdd=true&id_shop=$idshop';
    // await Dio().get(url).then((value) {
    //   setState(() {
    //     loadStatus = false;
    //   });

    //   if (value.toString() != 'null') {
    //     // print('value ==>> $value');

    //     var result = json.decode(value.data);
    //     //print('result ==>> $result');

    //     for (var map in result) {
    //       ProductModel productModel = ProductModel.fromJson(map);
    //       setState(() {
    //         productModels.add(productModel);
    //       });
    //     }
    //   } else {
    //     setState(() {
    //       status = false;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('สินค้าของคุณ'),
        ),
        body: Stack(
          children: <Widget>[
            loadStatus! ? MyStyle().showProgress() : showContent(),
            addProductButton(),
          ],
        ));
  }

  Widget showContent() {
    return status!
        ? showListFood()
        : Center(
            child: Text(
              'ยังไม่มีสินค้า',
              style: TextStyle(fontSize: 18),
            ),
          );
  }

  Widget addProductButton() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 40, right: 20),
                child: FloatingActionButton(
                  onPressed: () {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => AddProduct(
                        shopModel: shopModel!,
                      ),
                    );
                    Navigator.push(context, route)
                        .then((value) => {Navigator.pop(context)});
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ],
      );

  Widget showListFood() => ListView.builder(
      itemCount: productModels.length,
      itemBuilder: (context, index) => Card(
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: Image.network(
                    '${MyConstant().domain}/${productModels[index].image}',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${productModels[index].nameproduct}',
                          style: MyStyle().mainTitle,
                        ),
                        Text(
                          '${productModels[index].price} บาท',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          productModels[index].detail,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  deleteproduct(productModels[index]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));

  Future<Null> deleteproduct(ProductModel productModel) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle()
            .showTitleH2('คุณต้องการลบสินค้า ${productModel.nameproduct} ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  String url =
                      '${MyConstant().domain}/projectk6/deleteformid.php?isAdd=true&id_product=${productModel.idProduct}';
                  await Dio().get(url).then((value) => readProduct());
                },
                child: Text('ยืนยัน'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              )
            ],
          )
        ],
      ),
    );
  }
}