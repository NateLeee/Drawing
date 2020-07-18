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

struct ColorCyclingCircle: View {
    var amount = 0.0
    var steps = 100
    
    var body: some View {
        ZStack {
            ForEach(0 ..< steps) { value in
                Circle()
                    .inset(by: CGFloat(value) * 1.2)
                    .strokeBorder(LinearGradient(gradient: Gradient(colors: [
                        self.color(for: value, brightness: 1),
                        self.color(for: value, brightness: 0.5)
                    ]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
            }
        }
        .drawingGroup()
    }
    
    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(self.steps) + self.amount
        
        if targetHue > 1 {
            targetHue -= 1
        }
        
        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct Trapezoid: Shape {
    var insetAmount: CGFloat
    
    var animatableData: CGFloat {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + insetAmount, y: rect.minY))
        
        return path
    }
}

struct CheckerBoard: Shape {
    var rows: Int
    var cols: Int
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(Double(rows), Double(cols))
            
        }
        set {
            rows = Int(newValue.first)
            cols = Int(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let widthPerGrid: CGFloat = rect.width / CGFloat(cols)
        let heightPerGrid: CGFloat = rect.height / CGFloat(rows)
        
        // Draw rectangles
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                if (row + col).isMultiple(of: 2) {
                    // Should draw a rectangle
                    let startX = CGFloat(col) * widthPerGrid
                    let startY = CGFloat(row) * heightPerGrid
                    
                    // Move to the initial point
                    path.move(to: CGPoint(x: startX, y: startY))
                    
                    // Actually draw a rectangle
                    path.addLine(to: CGPoint(x: startX, y: startY + heightPerGrid))
                    path.addLine(to: CGPoint(x: startX + widthPerGrid, y: startY + heightPerGrid))
                    path.addLine(to: CGPoint(x: startX + widthPerGrid, y: startY))
                    path.addLine(to: CGPoint(x: startX, y: startY))
                    
                }
            }
        }
        
        //        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        //        path.addLine(to: CGPoint(x: 20, y: 0))
        //        path.addLine(to: CGPoint(x: 20, y: 20))
        //        path.addLine(to: CGPoint(x: 0, y: 20))
        //        path.addLine(to: CGPoint(x: 0, y: 0))
        //
        //        path.move(to: CGPoint(x: 40, y: 0))
        //        path.addLine(to: CGPoint(x: 60, y: 0))
        //        path.addLine(to: CGPoint(x: 60, y: 20))
        //        path.addLine(to: CGPoint(x: 40, y: 20))
        //        path.addLine(to: CGPoint(x: 40, y: 0))
        
        
        return path
    }
}

struct Spirograph: Shape {
    let innerRadius: Int
    let outerRadius: Int
    let distance: Int
    let amount: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let divisor = gcd(innerRadius, outerRadius)
        let outerRadius = CGFloat(self.outerRadius)
        let innerRadius = CGFloat(self.innerRadius)
        let distance = CGFloat(self.distance)
        let difference = innerRadius - outerRadius
        let endPoint = ceil(2 * CGFloat.pi * outerRadius / CGFloat(divisor)) * amount
        
        for theta in stride(from: 0, through: endPoint, by: 0.01) {
            var x = difference * cos(theta) + distance * cos(difference / outerRadius * theta)
            var y = difference * sin(theta) - distance * sin(difference / outerRadius * theta)
            
            x += rect.width / 2
            y += rect.height / 2
            
            if theta == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        
        return a
    }
}

struct Arrow: Shape {
    var length: CGFloat
    var width: CGFloat
    var thickness: CGFloat
    
    public var animatableData: CGFloat {
        get { thickness }
        set { thickness = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX - thickness - width, y: rect.minY + 20))
        path.addLine(to: CGPoint(x: rect.midX - thickness, y: rect.minY + 20))
        
        path.addLine(to: CGPoint(x: rect.midX - thickness, y: rect.minY + 20 + length))
        path.addLine(to: CGPoint(x: rect.midX + thickness, y: rect.minY + 20 + length))
        
        path.addLine(to: CGPoint(x: rect.midX + thickness, y: rect.minY + 20))
        path.addLine(to: CGPoint(x: rect.midX + thickness + width, y: rect.minY + 20))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct ContentView: View {
    
    @State private var rotationAngle: Double = 0
    @State private var arrowLength: CGFloat = 80
    @State private var arrowWidth: CGFloat = 5
    @State private var arrowThickness: CGFloat = 5
    
    var body: some View {
        VStack {
            Arrow(length: arrowLength, width: arrowWidth, thickness: arrowThickness)
                .frame(width: 300, height: 300)
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: rotationAngle))
            
            Group {
                Text("Arrow Length")
                    .padding(.horizontal)
                Slider(value: $arrowLength, in: 50 ... 280)
                    .padding(.horizontal)
                
                Text("Arrow Width")
                    .padding(.horizontal)
                Slider(value: $arrowWidth, in: 3 ... 20)
                    .padding(.horizontal)
                
                Stepper("Arrow Thickness", value: $arrowThickness.animation(.easeIn), in: 5 ... 11, step: 3)
                    .padding(.horizontal)
                
                Text("Rotation")
                    .padding(.horizontal)
                Slider(value: $rotationAngle, in: 0 ... 360)
                    .padding(.horizontal)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
