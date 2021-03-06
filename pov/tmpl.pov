global_settings { assumed_gamma 2.2 }

#declare MyTexture = texture {
	   finish {
	      phong 1.0
              reflection 1.0
	   }
	   pigment { color red 0 green 0 blue 0 }
}

camera {
   location  <25, 25, 25>
   direction <0, 0, 0.5>
   look_at   <25, 25, 251>
}

merge {
$spheres
}
light_source { 
	<0,0,0>
	color red 1 green 1 blue 1 
	fade_distance 1.00
	fade_power 1.0
	looks_like {
		sphere {
			<0,0,0>, 0.5
			pigment { rgb 1 }
			finish { ambient 1 }
    		}
	}
	translate <$lx, $ly, $lz> 
}


