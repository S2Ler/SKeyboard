import SwiftUI
import HidApi

struct DeviceWithUsageView: View {
  @State var status: String = "initial"
  @State var device: HidDevice?

  @State var deviceInfosStatus: String = ""
  @State var selectedDeviceInfo: HidDevice.Info?

  @State var writeReport: String = ""

  let item: Item

  var body: some View {
    Form {
      deviceDescriptionView
      statusLabel
      connectButton

      if let device {
        terminal(for: device)
      }
    }
  }

  private var connectButton: some View {
    Group {
      if device != nil {
        Button("Disconnect") {
          Task {
            status = "Disconnecting"
            self.device = nil
            status = "Disconnected"
          }
        }
      } else {
        if let selectedDeviceInfo {
          Button {
            Task {
              status = "Opening"
              do {
                device = try await hidApi.open(path: selectedDeviceInfo.path)

                status = "Opened device"
              } catch {
                status = "error: \(error.localizedDescription)"
              }
            }
          } label: {
            Text("Connect \(selectedDeviceInfo.path)")
          }
        } else {
          deviceInfosView
        }
      }
    }
  }

  @ViewBuilder
  private var deviceDescriptionView: some View {
    if let deviceInfo = selectedDeviceInfo {
      Text("path: \(deviceInfo.path)")
      Text("usagePage: \(deviceInfo.usagePage.description)")
      Text("usage: \(deviceInfo.usage.description)")
      Text("productString: \(deviceInfo.productString)")
      Text("manufacturerString: \(deviceInfo.manufacturerString)")
    } else {
      HStack {
        Text("Vendor ID:")
        Text(item.vendorId.description)
      }
      HStack {
        Text("Product ID:")
        Text(item.productId.description)
      }
      HStack {
        Text("Serial Number:")
        Text(item.serialNumber ?? "n/a")
      }
    }
  }

  private var statusLabel: some View {
    HStack {
      Text("Status")
      Text(status)
    }
  }

  @ViewBuilder
  private func terminal(for device: HidDevice) -> some View {
    TextField("Write", text: $writeReport)
    Button("Send") {
      Task {
        let report = reportStringToData(writeReport)
        status = "Sending \(report)"
        do {
          try await device.write(report)
          status = "Sent \(report.toHexString()) successfully; Reading feedback..."
          let feedback = try await device.read(timeout: 3)
          status = "Sent \(report.toHexString()) successfully; Got feedback \(feedback.toHexString())"
        } catch {
          status = "Sent \(report.toHexString()) with error=\(error)"
        }
      }
    }
  }

  @ViewBuilder
  private var deviceInfosView: some View {
    if !deviceInfosStatus.isEmpty {
      Text(deviceInfosStatus)
    }

    Button("Query") {
      Task {
        deviceInfosStatus = "Quering..."
        do {
          selectedDeviceInfo = try await hidApi.queryDevices(
            vendorId: item.vendorId,
            productId: item.productId,
            usagePage: item.usagePage,
            usage: item.usage
          ).first
          deviceInfosStatus = "Success"
        }
        catch {
          deviceInfosStatus = "Error: \(error.localizedDescription)"
        }
      }
    }
  }
}
