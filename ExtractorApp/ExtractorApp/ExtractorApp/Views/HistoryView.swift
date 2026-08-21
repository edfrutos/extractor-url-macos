import SwiftUI

/// Muestra el historial de extracciones (leído de history.jsonl, escrito
/// por el motor Python) y permite reabrir una entrada previa.
struct HistoryView: View {
    @StateObject private var historyVM = HistoryViewModel()
    @Environment(\.dismiss) private var dismiss
    let onReopen: (HistoryEntry) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Historial")
                    .font(.headline)
                Spacer()
                Button("Cerrar") { dismiss() }
            }
            .padding()

            Divider()

            if historyVM.entries.isEmpty {
                emptyState
            } else {
                List(historyVM.entries) { entry in
                    HistoryRow(entry: entry) {
                        onReopen(entry)
                        dismiss()
                    }
                }
                .listStyle(.inset)
            }
        }
        .frame(minWidth: 480, minHeight: 360)
        .onAppear { historyVM.reload() }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Sin extracciones todavía")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct HistoryRow: View {
    let entry: HistoryEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: entry.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(entry.isSuccess ? .green : .orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title ?? entry.url)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                    Text(entry.url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let outputType = entry.outputType {
                    Text(outputType.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HistoryView { _ in }
}
