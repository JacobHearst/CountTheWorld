//
// ContentView.swift
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var counters: [Counter]
    @State private var selectedCounter: Counter?
    @State private var showCounterCreator = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(counters) { counter in
                    CounterRow(counter: counter) {
                        selectedCounter = counter
                    }
                    .contextMenu {
                        Button("Edit") {
                            selectedCounter = counter
                        }
                        NavigationLink("History") {
                            HistoryView(history: counter.history, buckets: counter.buckets)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listRowSpacing(10)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    addCounterButton
                }
            }
            .sheet(item: $selectedCounter) {
                CounterEditor(counter: $0)
            }
            .sheet(isPresented: $showCounterCreator) {
                CounterEditor(counter: nil)
            }
            .overlay {
                if counters.isEmpty {
                    ContentUnavailableView {
                        Label("No counters found", systemImage: "questionmark.circle")
                    } description: {
                        addCounterButton
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(counters[index])
            }
        }
    }

    private var addCounterButton: some View {
        Button {
            showCounterCreator = true
        } label: {
            Label("Create a counter", systemImage: "plus")
                .help("Create a counter")
        }
    }
}

#Preview("Zero state") {
    ContentView()
        .modelContainer(for: Counter.self, inMemory: true)
}

#Preview("1 counter") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Counter.self, configurations: config)
    container.mainContext.insert(Counter(name: "Test counter", colorComponents: .random()))

    return ContentView()
        .modelContainer(container)
}

#Preview("2 counters") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Counter.self, configurations: config)

    for i in 0..<3 {
        let counter = Counter(name: "Test \(i)", colorComponents: .random())
        container.mainContext.insert(counter)
    }

    return ContentView()
        .modelContainer(container)
}

#Preview("3 counters") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Counter.self, configurations: config)

    for i in 0..<4 {
        let counter = Counter(name: "Test \(i)", colorComponents: .random())
        container.mainContext.insert(counter)
    }

    return ContentView()
        .modelContainer(container)
}

#Preview("Lots of counters") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Counter.self, configurations: config)

    for i in 0..<50 {
        let counter = Counter(name: "Test \(i)", colorComponents: .random())
        container.mainContext.insert(counter)
    }

    return ContentView()
        .modelContainer(container)
}
