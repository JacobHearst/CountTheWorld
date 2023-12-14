//
// CounterRowItem.swift
//

import SwiftUI
import SwiftData

struct CounterRowItem: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var counter: Counter
    private var counterEvents: Query<CounterChangeEvent, [CounterChangeEvent]>
    private let foregroundColor: Color

    init(counter: Counter) {
        self.counter = counter
        self.counterEvents = Query(filter: counter.changeEventPredicate)
        foregroundColor = counter.color.isDark ? .white : .black
    }

    var body: some View {
        Group {
            GeometryReader { geometry in
                HStack {
                    if !counter.disallowSubtraction {
                        Image(systemName: "minus")
                            .help("Decrement the counter")
                    }

                    Spacer()

                    VStack {
                        Text(counter.name)
                            .font(.headline)
                        Text(counter.count.description)
                    }

                    Spacer()

                    if !counter.disallowSubtraction {
                        Image(systemName: "plus")
                            .help("Increment the counter")
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .foregroundStyle(foregroundColor)
                .onTapGesture {
                    increment(isNegative: $0.x <= geometry.size.width / 2)
                }
            }
        }
        .listRowBackground(counter.color)
        .padding(20)
        .padding(.bottom)
    }

    private func increment(isNegative: Bool) {
        counter.count += isNegative && !counter.disallowSubtraction ? -1 * counter.incrementStep : counter.incrementStep
        modelContext.insert(CounterChangeEvent(counter: counter, newValue: counter.count))
    }
}

#Preview {
    CounterRowItem(counter: Counter(name: "Test", colorComponents: Color.red.resolve(in: .init())))
}
