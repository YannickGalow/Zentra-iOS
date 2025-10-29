import SwiftUI

struct ThemeRow: View {
    let theme: ThemeModel

    var body: some View {
        HStack {
            Text(theme.name)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(6)
    }
}
