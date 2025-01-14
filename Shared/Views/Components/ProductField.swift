//
//  ProductField.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 13.01.21.
//

import SwiftUI

struct ProductField: View {
    @StateObject var grocyVM: GrocyViewModel = .shared
    
    @Binding var productID: Int?
    var description: String
    
    @State private var searchTerm: String = ""
    #if os(iOS)
    @State private var isScannerFlash = false
    @State private var isScannerFrontCamera = false
    @State private var isShowingScanner: Bool = false
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            searchTerm = code
        case .failure(let error):
            grocyVM.postLog(message: "Scanning for product failed. \(error)", type: .error)
        }
    }
    #endif
    
    private func getBarcodes(pID: Int) -> [String] {
        grocyVM.mdProductBarcodes.filter{$0.productID == pID}.map{$0.barcode}
    }
    
    private var sortedProducts: MDProducts {
        grocyVM.mdProducts.sorted(by: {$0.name < $1.name})
    }
    
    private var filteredProducts: MDProducts {
        sortedProducts.filter {
            searchTerm.isEmpty ? true : ($0.name.localizedCaseInsensitiveContains(searchTerm) || getBarcodes(pID: $0.id).contains(searchTerm))
        }
    }
    
    #if os(iOS)
    var body: some View {
        Picker(selection: $productID, label: Label(LocalizedStringKey(description), systemImage: MySymbols.product).foregroundColor(.primary), content: {
            HStack {
                SearchBar(text: $searchTerm, placeholder: "str.search")
                Button(action: {
                    isShowingScanner.toggle()
                }, label: {
                    Image(systemName: MySymbols.barcodeScan)
                })
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: getSavedCodeTypes().map{$0.type}, scanMode: .once, simulatedData: "5901234123457", isFrontCamera: $isScannerFrontCamera, completion: self.handleScan)
                        .overlay(
                            HStack{
                                Button(action: {
                                    isScannerFlash.toggle()
                                    toggleTorch(on: isScannerFlash)
                                }, label: {
                                    Image(systemName: isScannerFlash ? "bolt.circle" : "bolt.slash.circle")
                                        .font(.title)
                                })
                                .disabled(!checkForTorch())
                                .padding()
                                if getFrontCameraAvailable() {
                                    Button(action: {
                                        isScannerFrontCamera.toggle()
                                    }, label: {
                                        Image(systemName: MySymbols.changeCamera)
                                            .font(.title)
                                    })
                                    .padding()
                                }
                            }
                            , alignment: .topTrailing)
                }
            }
            Text("").tag(nil as Int?)
            ForEach(filteredProducts, id: \.id) { productElement in
                Text(productElement.name).tag(productElement.id as Int?)
            }
        }).pickerStyle(DefaultPickerStyle())
    }
    #elseif os(macOS)
    var body: some View {
        Picker(selection: $productID, label: Label(LocalizedStringKey(description), systemImage: MySymbols.product), content: {
            Text("").tag(nil as Int?)
            ForEach(filteredProducts, id: \.id) { productElement in
                Text(productElement.name).tag(productElement.id as Int?)
            }
        })
    }
    #endif
}

struct ProductField_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            Form{
                ProductField(productID: Binding.constant(1), description: "str.stock.buy.product")
            }
        }
    }
}
