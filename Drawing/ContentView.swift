//
//  ContentView.swift
//  Drawing
//
//  Created by Nate Lee on 7/14/20.
//  Copyright © 2020 Nate Lee. All rights reserved.
//

import SwiftUI


struct Arc: Shape {
    // var radius: CGFloat
    var startAngle: Double
    var endAngle: Double
    var clockwise: Bool = true
    
    func path(in rect: CGRect) -> Path {
        // Solution to counter-intuivie swift drawing defaults
        
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: Angle(degrees: startAngle),
            endAngle: Angle(degrees: endAngle),
            clockwise: clockwise
        )
        
        return path
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
        ZStack {
            Triangle()
                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .bevel))
                .frame(width: 150, height: 150)
            
            Arc(startAngle: 0, endAngle: 100)
                .stroke(Color.red.opacity(0.3), style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .frame(width: 200, height: 200)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
