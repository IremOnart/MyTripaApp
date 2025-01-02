//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 2.01.2025.
//

import Foundation
import SwiftUICore
import SwiftUI

struct ExpenseDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State var expense: ExpensesEntity
    
    let categories = ["Yemek", "Ulaşım", "Alışveriş", "Fatura", "Diğer"]
    
    @State private var expenseName: String
    @State private var expenseAmount: String
    @State private var selectedCategory: String
    @State private var selectedDate: Date
    
    init(expense: ExpensesEntity?) {
        _expense = State(initialValue: expense ?? ExpensesEntity())
        _expenseName = State(initialValue: expense?.name ?? "")
        _expenseAmount = State(initialValue: "\(expense?.amount ?? 0.0)")
        _selectedCategory = State(initialValue: expense?.category ?? "Diğer")
        _selectedDate = State(initialValue: expense?.date ?? Date())
    }
    
    var body: some View {
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
                Button(action: updateExpense) {
                    Text("Güncelle")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .navigationTitle("Gider Detayları")
    }
    
    func updateExpense() {
        // Gider adı boş değilse güncelle
        if !expenseName.isEmpty {
            expense.name = expenseName
        } else {
            print("Gider adı boş!")
        }

        // Miktar boş değilse ve geçerli bir sayıysa güncelle
        if let amount = Double(expenseAmount), !expenseAmount.isEmpty {
            expense.amount = amount
        } else {
            print("Miktar boş veya geçerli bir sayı değil!")
        }

        // Kategori boş değilse güncelle
        if !selectedCategory.isEmpty {
            expense.category = selectedCategory
        } else {
            print("Kategori boş!")
        }

        // Tarih boş değilse güncelle
        if selectedDate != Date() {
            expense.date = selectedDate
        } else {
            print("Tarih geçerli değil!")
        }

        // Değişiklikleri kaydet
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Güncelleme işleminden sonra sayfayı kapat
            print("Gider başarıyla güncellendi.")
        } catch {
            print("Gider güncellenemedi: \(error.localizedDescription)")
        }
    }
}
