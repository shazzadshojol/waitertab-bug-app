
import 'package:get/get.dart';
import 'package:waiter/app/core/values/mr_config.dart';
import 'package:waiter/app/core/values/mr_url.dart';
import 'package:waiter/app/data/models/product.dart';
import 'package:waiter/app/data/models/sales.dart';
import 'package:waiter/app/data/models/table.dart';
class CardProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'YOUR-API-URL';
  }
  Future<Sales> postSales(Sales sales) async {
    try
    {
      final String postUrl="${MrConfig.base_app_url}resturant_salama/api/v1/sales/postsales?api-key=${MrConfig.mr_api_key}";
      print(sales.toMap());
      print('sales.toMap()');
      Response response = await post(postUrl,sales.toMap());
      if (response.statusCode == 200) {
        return Sales.fromJSON(response.body['sale']);
      } else {
        return null;
      }
    }catch(exception) {
      return Future.error(exception.toString());
    }

  }
  Future<List<TableModel>> getTables() async {
    final String tableUrl="${MrUrl.get_table_list_url}";
    Response response = await get(tableUrl);
    if (response.statusCode == 200) {
      return tableModelFromJson(response.body['data']);
    } else {
      // return Future.error(response.statusText);
      return null;
    }
  }
  Future<Product> getOptions(String productId) async {
    final String optionUrl="${MrConfig.base_app_url}resturant_salama/api/v1/products?code=$productId&include=items&api-key=${MrConfig.mr_api_key}";
    Response response = await get(optionUrl);
    if (response.statusCode == 200) {
      return Product.fromJson(response.body);
    } else {
      // return Future.error(response.statusText);
      return null;
    }
  }


 /* Future<Response<Basket>> postCity(body) =>
      post<Basket>('http://192.168.0.101:3000/items', body,
          decoder: (obj) => Basket.fromJson(obj));*/
}
