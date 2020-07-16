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


struct ContentView: View {
    var body: some View {
        Arc(startAngle: -90, endAngle: 90)
            //.stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .butt, lineJoin: .bevel))
            .strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .butt, lineJoin: .bevel))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
