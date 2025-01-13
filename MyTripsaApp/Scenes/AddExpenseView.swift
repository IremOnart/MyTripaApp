//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 29.12.2024.
//

import SwiftUI
import GoogleSignIn

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode // Sayfayı kapatmak için
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var selectedCategory: String = "Diğer"
    @State private var selectedDate: Date = Date() // Varsayılan olarak bugünün tarihi
    @StateObject var trips: TripEntity

    let categories = ["Yemek", "Ulaşım", "Alışveriş", "Fatura", "Diğer"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gider Bilgileri")) {
                    TextField("Gider Adı", text: $expenseName)
                    
                    TextField("Miktar", text: $expenseAmount)
                        .keyboardType(.decimalPad) // Sadece sayısal klavye
                }
                
                Section(header: Text("Kategori")) {
                    Picker("Kategori Seçin", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Tarih Seçimi")) {
                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                Section {
                    Button(action: saveExpense) {
                        Text("Kaydet")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Yeni Gider Ekle")
        }
    }
    
    func saveExpense() {
        guard !expenseName.isEmpty, !expenseAmount.isEmpty, let amount = Double(expenseAmount) else {
            print("Tüm alanları doldurun!")
            return
        }
        
        // Google SignIn ile kullanıcı ID'sini al
        guard let userId = GIDSignIn.sharedInstance.currentUser?.userID else {
            print("User not signed in!")
            return
        }

        let newExpense = ExpensesEntity(context: viewContext)
        newExpense.name = expenseName
        newExpense.amount = amount
        newExpense.category = selectedCategory
        newExpense.date = selectedDate
        newExpense.trip = trips // Trip ile ilişkilendir

        // Kullanıcı ID'sini gider ile ilişkilendir
        newExpense.userID = userId

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Kaydetme işleminden sonra sayfayı kapat
            print("Gider başarıyla kaydedildi.")
        } catch {
            print("Gider kaydedilemedi: \(error.localizedDescription)")
        }
        
        print("Gider Kaydedildi: \(expenseName), \(amount), \(selectedCategory), \(selectedDate), UserID: \(userId)")
        presentationMode.wrappedValue.dismiss()
    }

}

//struct AddExpenseView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddExpenseView()
//    }
//}

