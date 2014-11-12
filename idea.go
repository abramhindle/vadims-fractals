package main

import (
	"fmt"
	"math"
	"github.com/skelterjohn/go.matrix" 
)

type ScoEvent struct {
	instr string
	when float64
	dur  float64
	loud float64
}

func (e ScoEvent) PrintSco() {
	fmt.Printf("i%s %f %f %f\n", e.instr, e.when, e.dur, e.loud)
}

func CsoundIt(instr string, when float64, loud float64) {
	fmt.Printf("i%s %f %f\n", instr, when, loud)
}


type Model struct {
	Decay float64
	MaxDepth int
	Speed float64 // speed of sound in m/s
	              // in that material 300m/s is air
}

type Reflector struct {
	Distance float64
	Angle float64	
}

func Bounce(proto ScoEvent, reflectors []Reflector, model Model) []ScoEvent {
	now := proto.when
	score := make([]ScoEvent, 0)
	for _, reflector := range reflectors {
		if ( reflector.Angle > -90.0 && reflector.Angle < 90.0) {
			x := proto
			x.loud = x.loud * (1.0 - math.Abs(reflector.Angle)/90.0) * (1 - model.Decay)
			x.when = now + reflector.Distance / model.Speed
			score = append(score, x)
		}
	}
	return score
}



func PrintScore(score []ScoEvent) {
	for _, elm := range score {
		elm.PrintSco()
	}
}

func reflectorTest() {
	s := ScoEvent{"\"sine\"", 0.0, 0.1, 1.0}
	s.PrintSco()
	reflectors := []Reflector{ Reflector{100.0,0.0}, Reflector{50.0,0.0}, Reflector{1000.0,0.0}, Reflector{1000.0,99.0}, Reflector{666,45.0} }
	model := Model{ 0.9, 1, 300.0 }
	score := Bounce(s,reflectors, model)
	PrintScore(score)
}

func DBounce(proto ScoEvent, index int, m *matrix.DenseMatrix, model Model) []ScoEvent {
	now := proto.when
	rows := m.Rows()
	score := make([]ScoEvent, 0)
	for i := 0; i < rows; i++ {
		if (i!=index) {
			x := proto
			x.loud = x.loud * (1 - model.Decay)
			x.when = now + m.Get(index, i) / model.Speed
			score = append(score, x)			
		}
	}
	return score
}

func main() {
	m := matrix.MakeDenseMatrix([]float64{
		0.0,   100.0, 300.0,
		100.0,   0.0, 200.0,
		300.0, 200.0,   0.0,
	},3,3)
	s := ScoEvent{"\"sine\"", 0.0, 0.1, 1.0}
	s.PrintSco()
	model := Model{ 0.9, 1, 300.0 }
	score := DBounce(s,0,m,model)
	PrintScore(score)	
}
