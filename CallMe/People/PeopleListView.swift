//
//  PeopleListView.swift
//  CallMe
//
//  Created by Mehmet Tarhan on 19/12/2023.
//

import SwiftUI

struct PeopleListView: View {
    @ObservedObject private var model = PeopleData()

    var onSelection: (Person) -> Void

    var body: some View {
        List {
            ForEach(model.people) { person in
                HStack(spacing: 20) {
                    PersonRow(person: person)

                    if !person.isMe {
                        Button {
                            onSelection(person)
                        } label: {
                            HStack {
                                Image(systemName: "chevron.forward")
                                Image(systemName: "phone.fill")
                                    .font(.largeTitle)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            model.load()
        }
    }
}

struct PersonRow: View {
    var person: Person

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "iphone")
                    .foregroundStyle(Color.purple)

                Text(person.deviceName)
                Spacer()
                Text(person.deviceType)
            }
            .padding(.vertical, 4)

            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(Color.purple)

                Text(person.id)
                    .font(.footnote)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical, 4)

            if let deviceRegion = person.deviceRegion {
                HStack {
                    Image(systemName: "mappin.and.ellipse.circle.fill")
                        .foregroundStyle(Color.purple)

                    Text(deviceRegion)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding(2)
    }
}

#Preview {
    PeopleListView { _ in
    }
}
