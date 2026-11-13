//
//  ClusteredExpensesMap+Coordinator.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import MapKit
import SwiftUI

extension ClusteredExpensesMap {
    final class Coordinator: NSObject, MKMapViewDelegate {
        private var parent: ClusteredExpensesMap
        private var annotationsByID: [UUID: ExpenseMapAnnotation] = [:]
        private var lastFitRequest: Int
        private var needsFit: Bool
        private var animatesFit = false

        init(_ parent: ClusteredExpensesMap) {
            self.parent = parent
            lastFitRequest = parent.fitRequest
            needsFit = parent.cameraState.camera == nil
        }

        func update(_ parent: ClusteredExpensesMap, on map: MKMapView) {
            self.parent = parent
            let itemsByID = Dictionary(parent.items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            let removed = annotationsByID.values.filter { itemsByID[$0.item.id] != $0.item }
            map.removeAnnotations(removed)
            for annotation in removed {
                annotationsByID.removeValue(forKey: annotation.item.id)
            }

            let added = itemsByID.values
                .filter { annotationsByID[$0.id] == nil }
                .map { ExpenseMapAnnotation(item: $0) }
            for annotation in added {
                annotationsByID[annotation.item.id] = annotation
            }
            map.addAnnotations(added)

            if lastFitRequest != parent.fitRequest {
                lastFitRequest = parent.fitRequest
                needsFit = true
                animatesFit = true
            }
            fitIfNeeded(on: map)
        }

        func fitIfNeeded(on map: MKMapView) {
            guard needsFit, map.bounds.width > 0, map.bounds.height > 0,
                  let rect = ExpenseMapViewport.visibleRect(for: parent.items.map { $0.coordinate.coreLocationCoordinate }) else {
                return
            }

            needsFit = false
            map.setVisibleMapRect(rect, edgePadding: map.layoutMargins, animated: animatesFit)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.cameraState.camera = mapView.camera.copy() as? MKMapCamera
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: annotation) as? MKMarkerAnnotationView else {
                    return nil
                }

                view.subtitleVisibility = .hidden
                view.glyphText = String(cluster.memberAnnotations.count)

                return view
            }

            guard let expense = annotation as? ExpenseMapAnnotation,
                  let view = mapView.dequeueReusableAnnotationView(withIdentifier: "expense", for: annotation) as? MKMarkerAnnotationView else {
                return nil
            }

            view.clusteringIdentifier = "expenses"
            view.markerTintColor = UIColor(expense.item.color)
            view.glyphImage = UIImage(systemName: expense.item.icon)
            view.glyphTintColor = .systemBackground
            
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            mapView.deselectAnnotation(annotation, animated: false)

            if let expense = annotation as? ExpenseMapAnnotation {
                parent.onSelectExpense(expense.item.id)
            } else if let cluster = annotation as? MKClusterAnnotation {
                let expenseIDs = cluster.memberAnnotations.compactMap { ($0 as? ExpenseMapAnnotation)?.item.id }
                parent.onSelectGroup(expenseIDs)
            }
        }
    }
}
