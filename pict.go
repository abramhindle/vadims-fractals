package main

import (
	"flag"
	"math"
	"os"
	"fmt"
	"image"
	"image/png"
	"image/color"
	"github.com/youpy/go-wav"
)

type ScoEvent struct {
	instr string
	when float64
	dur  float64
	loud float64
	pitch float64
}

func (e ScoEvent) PrintSco() {
	fmt.Printf("i%s %f %f %f %f\n", e.instr, e.when, e.dur, e.loud, e.pitch)
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

func HistToSamples(hist []float64, sampleDist int) []wav.Sample{
	histlen := len(hist) - 1
	n := histlen + (histlen - 1)*sampleDist
	samples := make([]wav.Sample,n)
	for i := 0; i < histlen; i++ {
		value := int(32000 * hist[i])
		sample := wav.Sample{[2]int{value,0}}
		samples[i*(sampleDist+1)] = sample
	}
	return samples
}

func HistToWav(hist []float64, sampleDist int, filename string) {
	samples := HistToSamples(hist, sampleDist)
	f, err := os.Create(filename)
	defer func() {
		check(f.Close())
	}()
	check(err)
	wavwriter := wav.NewWriter(f, uint32(len(samples)), 1, 44100, 16)
	check(wavwriter.WriteSamples(samples))
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
	last := flag.Int("last", 451, "n frames")
	size_of_node := flag.Float64("size",10.00,"size of node") // huge
	speed_through_material := flag.Float64("speed",5800.0,"speed through material") // quartz
	decay := flag.Float64("decay",0.5,"How much energy each reflection takes")
	maxreflect := flag.Int("reflects",3,"How many reflects to expect -- sort of loudness")
	seconds := flag.Float64("seconds",7.0,"How many seconds long")
	flag.Parse()

	model := Model{ *decay, 1, *speed_through_material / *size_of_node , *maxreflect}
	for imagi := 0; imagi <= *last; imagi++ {
		filename    := fmt.Sprintf("pov/50povs/%04d.png",imagi)		

		img := LoadPNG(filename)
		hist := Histogram(img)

		wavfilename := fmt.Sprintf("convs/%04d-%f-%f.wav",imagi,*size_of_node,*speed_through_material)		
		sampleDist := int(44100.0 * (*size_of_node)/(*speed_through_material))
		if (sampleDist < 1) {
			sampleDist = 1
		}
		if _, err := os.Stat(wavfilename); os.IsNotExist(err) {
			HistToWav(hist, sampleDist,wavfilename)
		}
		//fmt.Printf("%v\n",hist)
		s := ScoEvent{"\"sine\"", float64(imagi)/float64(*last+1.0)*(*seconds), 0.05, 0.95, 440 - 24.69*float64(imagi)/452.0}
		//s.PrintSco()		

		for i := 0 ;i < len(hist) - 1; i++ {
			ss := DBounce(s, 0.1+(*size_of_node)*float64(i), hist[i], model)
			ss.PrintSco()
		}
	}
}
