package main

import (
	"math"
	"os"
	"fmt"
	"image"
	"image/png"
	"image/color"
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
	MaxReflects int
}



func check(e error) {
    if e != nil {
        panic(e)
    }
}

func PrintScore(score []ScoEvent) {
	for _, elm := range score {
		elm.PrintSco()
	}
}

func LoadPNG(fileName string) image.Image {
	f, err := os.Open(fileName)
	check(err)
	img, err := png.Decode(f)
	check(err)
	return img
}

func iterImage(img image.Image, f (func(color.Color, int, int))) {
	b := img.Bounds()
	for y := b.Min.Y; y < b.Max.Y; y++ {
		for x := b.Min.X; x < b.Max.X; x++ {
			f(img.At(x, y),x,y)
		}
	}
}

func getPixels(img image.Image) int {
	b := img.Bounds()
	return (b.Max.Y - b.Min.Y) * (b.Max.X - b.Min.X)
}

func Histogram(img image.Image) []float64 {
	hist := make([]float64,256)
	getRed := func (c color.Color, x, y int) {
		r,_,_,_ := c.RGBA()		
		hist[255 - r/256] += 1
	}
	iterImage(img, getRed)
	p := getPixels(img)
	for i := 0; i < len(hist); i++ {
		hist[i] /= float64(p)
	}	
	return hist
}

func DBounce(proto ScoEvent, distance float64, proportion float64, model Model) ScoEvent {
	now := proto.when
	loudmodifier := float64(model.MaxReflects)/math.Log(1.0/proportion)
	x := proto
	x.loud = loudmodifier*(x.loud * (1 - model.Decay))
	x.when = now + distance / model.Speed
	return x
}



func main() {      
	img := LoadPNG("pov/50povs/0001.png")
	hist := Histogram(img)
	//fmt.Printf("%v\n",hist)
	s := ScoEvent{"\"sine\"", 0.0, 0.1, 1.0}
	s.PrintSco()
	model := Model{ 0.9, 1, 1000.0, 5}
	for i := 0 ;i < len(hist) - 1; i++ {
		ss := DBounce(s, 0.1+float64(i), hist[i], model)
		ss.PrintSco()
	}
}
