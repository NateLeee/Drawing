//
//  ContentView.swift
//  Drawing
//
//  Created by Nate Lee on 7/14/20.
//  Copyright © 2020 Nate Lee. All rights reserved.
//

import SwiftUI


struct Arc: InsettableShape {
    var startAngle: Double
    var endAngle: Double
    var clockwise: Bool = true
    
    var insetAmount: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        // Solution to counter-intuivie swift drawing defaults
        let modifiedStart = startAngle - 90
        let modifiedEnd = endAngle - 90
        
        var path = Path()
        
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2 - insetAmount,
            startAngle: Angle(degrees: modifiedStart),
            endAngle: Angle(degrees: modifiedEnd),
            clockwise: !clockwise
        )
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxX))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxX))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct Flower: Shape {
    var pedalWidth: CGFloat
    var pedalOffset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for rotationDegree in stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 8) {
            let rotation = CGAffineTransform(rotationAngle: rotationDegree)
            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
            
            // Draw an ellipse then
            let pedal = Path(ellipseIn: CGRect(x: pedalOffset, y: 0, width: pedalWidth, height: rect.width / 2))
            let rotatedPedal = pedal.applying(position)
            
            path.addPath(rotatedPedal)
        }
        
        return path
    }
    
    
}

struct ContentView: View {
    
    @State private var pedalWidth: Double = 30
    @State private var pedalOffset: Double = 30
    
    var body: some View {
        VStack {
            Text("Hell0")
                .frame(width: 300, height: 100)
                .border(ImagePaint(
                    image: Image("example"),
                    sourceRect: CGRect(x: 0.22, y: 0.15, width: 0.8, height: 0.7),
                    scale: 0.3
                ), width: 40)
                .padding()
            
            Capsule()
                .strokeBorder(ImagePaint(image: Image("example"), scale: 0.2), lineWidth: 40)
                .frame(width: 250, height: 100)
            
            Flower(pedalWidth: CGFloat(pedalWidth), pedalOffset: CGFloat(pedalOffset))
                .fill(Color.blue, style: FillStyle(eoFill: true))
                .padding([.horizontal, .bottom])
            
            Text("Pedal Offset")
            Slider(value: $pedalOffset, in: -40 ... 40)
                .padding([.horizontal, .bottom])
            
            Text("Pedal Width")
            Slider(value: $pedalWidth, in: 1 ... 100)
                .padding([.horizontal, .bottom])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
