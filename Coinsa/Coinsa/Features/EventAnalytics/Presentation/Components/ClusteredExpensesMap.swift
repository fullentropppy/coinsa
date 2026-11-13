//
//  ClusteredExpensesMap.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import MapKit
import SwiftUI

/// Карта трат с системной кластеризацией пересекающихся меток.
struct ClusteredExpensesMap: UIViewRepresentable {
    let items: [ExpenseMapItem]
    let contentInsets: EdgeInsets
    let fitRequest: Int
    let cameraState: ExpenseMapCameraState
    let onSelectExpense: (UUID) -> Void
    let onSelectGroup: ([UUID]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ExpensesMKMapView {
        let map = ExpensesMKMapView()
        map.delegate = context.coordinator
        map.showsScale = true
        map.insetsLayoutMarginsFromSafeArea = false
        map.pointOfInterestFilter = .excludingAll
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "expense")
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        map.onLayout = { [weak coordinator = context.coordinator] map in
            coordinator?.fitIfNeeded(on: map)
        }

        if let camera = cameraState.camera {
            map.setCamera(camera, animated: false)
        }

        return map
    }

    func updateUIView(_ map: ExpensesMKMapView, context: Context) {
        map.layoutMargins = UIEdgeInsets(
            top: contentInsets.top + MapLayout.controlsInset,
            left: contentInsets.leading + MapLayout.controlsInset,
            bottom: contentInsets.bottom + MapLayout.controlsInset,
            right: contentInsets.trailing + MapLayout.controlsInset
        )
        context.coordinator.update(self, on: map)
    }

    static func dismantleUIView(_ map: ExpensesMKMapView, coordinator: Coordinator) {
        map.delegate = nil
        map.onLayout = nil
    }
}

/// Карта, откладывающая первоначальное центрирование до получения размеров.
final class ExpensesMKMapView: MKMapView {
    var onLayout: ((MKMapView) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(self)
    }
}
