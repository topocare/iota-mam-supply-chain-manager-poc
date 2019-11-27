import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supply_chain_manager/appState/ProductChannelLoader.dart';
import 'package:supply_chain_manager/appState/ScmAppState.dart';
import 'package:supply_chain_manager/messages/Buy.dart';
import 'package:supply_chain_manager/messages/ProductionDetail.dart';
import 'package:supply_chain_manager/messages/Sell.dart';
import 'package:supply_chain_manager/widgets/DetailsViewFutureItem.dart';
import 'package:supply_chain_manager/widgets/DetailsViewItem.dart';
import 'package:supply_chain_manager/widgets/DetailsViewList.dart';
import 'package:supply_chain_manager/widgets/DetailsViewTitle.dart';
import 'package:supply_chain_manager/widgets/CustomButton.dart';


/// Lists all information of a product meta-channel.
/// Offers button to check if additional information is available.
class ProductChannelBody extends StatelessWidget {
  final ProductChannelLoader productLoader;

  ProductChannelBody(this.productLoader) {
    productLoader.getManufacturerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
            //reverse: true,
            child: DetailsViewList(
                children: [
                  DetailsViewTitle(title: "Manufacturer"),
                  DetailsViewFutureItem(title: "Name: ", future: productLoader.manufacturerDescription),
                  DetailsViewFutureItem(title: "Confirmation:", future: productLoader.manufacturerConfirmed),
                  Consumer<ScmAppState>(builder: (context, appState, child) {
                    return DetailsViewItem(title: "trusted:", value: "${appState.isTrustedManufacturer(productLoader.product.manufacturerRoot)}");
                  }),
                  DetailsViewItem(title: "Root:",
                      value: productLoader.product.manufacturerRoot, /*() {
                    appState.selectedManufacturer= appState.selectedProduct.manufacturer;
                    Navigator.pushNamed(context, '/ManufacturerDetails');
                  }*/),
                  DetailsViewTitle(title: "Product"),
                  DetailsViewItem(title: "Product-ID:", value: '${productLoader.product.productId}'),
                  DetailsViewItem(title: "Type:", value: productLoader.product.typeId),
                  DetailsViewItem(title: "Description:", value: productLoader.product.description),
                  DetailsViewItem(title: "Root:", value: productLoader.product.root),
                  DetailsViewItem(title: "nextRoot:", value: productLoader.product.nextRoot),
                  getProductionDetailItems(productLoader),
                ])));
  }

  Widget getProductionDetailItems(ProductChannelLoader loader) {
    List<Widget> list = List<Widget>();

    loader.productionDetailsList.forEach((productUpdate) {
      if (productUpdate is ProductionDetail) {
        list.add(DetailsViewTitle(title: "Production Details:"));
        list.add(DetailsViewItem(title: "Timestamp:", value: productUpdate.timeStamp));
        list.add(DetailsViewItem(title: "Batch-Number:", value: productUpdate.batchNumber));
        list.add(DetailsViewItem(title: "Production Line:", value: productUpdate.productionLine));
      }
      if (productUpdate is Sell) {
        list.add(DetailsViewTitle(title: "Handover"));
        list.add(DetailsViewItem(title: "Timestemp:", value: productUpdate.timeStamp));
      }
      if (productUpdate is Buy) {
        list.add(DetailsViewItem(title: "Bought by:", value: productUpdate.buyerDescription));
      }
    });
    if (loader.isLoading) {
      list.add(Center(child: CircularProgressIndicator()));
      list.add(CustomButton(
        title: "stop loading",
        onPressed: () {
          loader.stopLoadingProductUpdate();
        },
      ));
    } else {
      list.add(CustomButton(
        title: "load details",
        onPressed: () {
          loader.startLoadingProductionDetails();
        },
      ));
    }

    return DetailsViewList(
      children: list,
    );
  }
}
