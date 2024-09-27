import SwiftUI

struct ContentView: View {
    // Определение структуры Product внутри ContentView
    struct Product: Identifiable, Equatable {
        let id = UUID()
        var name: String
    }
    
    // Состояния для управления списком продуктов и UI
    @State private var products: [Product] = []            // Список продуктов
    @State private var newProductName: String = ""         // Новое название продукта для добавления
    @State private var showDeleteAlert: Bool = false       // Показать ли предупреждение перед удалением
    @State private var productToDelete: Product? = nil     // Продукт, который нужно удалить
    @State private var showEditAlert: Bool = false         // Показать ли алерт для редактирования
    @State private var productToEdit: Product? = nil       // Продукт, который нужно редактировать
    @State private var editedProductName: String = ""       // Новое название продукта при редактировании

    var body: some View {
        NavigationView {
            VStack {
                // Верхняя часть: поле ввода и кнопка добавления продукта
                HStack {
                    TextField("Введите название продукта", text: $newProductName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: addProduct) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 8)
                }
                .padding()
                
                // Список продуктов
                List {
                    ForEach(products) { product in
                        HStack {
                            Text(product.name)
                            
                            Spacer()
                            
                            // Кнопка редактирования продукта
                            Button(action: {
                                productToEdit = product
                                editedProductName = product.name
                                showEditAlert = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.green)
                            }
                            .padding(.trailing, 8)
                            
                            // Кнопка удаления продукта
                            Button(action: {
                                productToDelete = product
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteProducts) // Поддержка свайпа для удаления
                }
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .navigationBarTitle("Список продуктов", displayMode: .inline)
            .navigationBarItems(trailing: EditButton()) // Кнопка редактирования списка (удаление через свайп)
            // Предупреждение перед удалением
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Подтверждение удаления"),
                    message: Text("Вы уверены, что хотите удалить \"\(productToDelete?.name ?? "")\"?"),
                    primaryButton: .destructive(Text("Удалить")) {
                        if let product = productToDelete {
                            removeProduct(product)
                        }
                    },
                    secondaryButton: .cancel {
                        productToDelete = nil // Сбросить продукт для удаления
                    }
                )
            }
            // Окно редактирования продукта через Alert
            .alert("Изменить продукт", isPresented: $showEditAlert) {
                TextField("Новое название", text: $editedProductName)
                
                Button("Сохранить", action: {
                    if let product = productToEdit {
                        updateProduct(oldProduct: product, newName: editedProductName)
                    }
                })
                
                Button("Отмена", role: .cancel, action: {
                    productToEdit = nil
                })
            }
        }
    }
    
    // MARK: - Функции
    
    // Функция для добавления нового продукта
    func addProduct() {
        let trimmedName = newProductName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return } // Проверка на пустую строку
        let newProduct = Product(name: trimmedName)
        products.append(newProduct) // Добавить продукт в список
        newProductName = "" // Очистить поле ввода
    }
    
    // Функция для удаления выбранного продукта
    func removeProduct(_ product: Product) {
        if let index = products.firstIndex(of: product) {
            products.remove(at: index) // Удалить продукт из списка
        }
    }
    
    // Функция для обновления названия продукта
    func updateProduct(oldProduct: Product, newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return } // Проверка на пустую строку
        if let index = products.firstIndex(of: oldProduct) {
            products[index].name = trimmedName // Обновить название продукта
        }
    }
    
    // Функция для удаления продуктов с помощью свайпа
    func deleteProducts(at offsets: IndexSet) {
        products.remove(atOffsets: offsets) // Удаление по индексу
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
