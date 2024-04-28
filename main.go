package main

import "html/template"
import "net/http"
import "time"
import "fmt"
import "github.com/joho/godotenv"
import owm "github.com/briandowns/openweathermap"
import "os"

type Button struct {
	Name string
	Icon string
	Link string
}

type Homepage struct {
	Time string
	Buttons []Button
	Weather string
}

func getWeather() string {
	godotenv.Load()
	var apiKey = os.Getenv("OWM_API_KEY")
	wtr, err := owm.NewCurrent("C", "ru", apiKey)
	if err != nil {
		panic(err)
    }
	wtr.CurrentByName("Moscow")
	return fmt.Sprintf("%d°C", int(wtr.Main.Temp))
}

func handler(w http.ResponseWriter, req *http.Request) {
	tmpl, _ := template.ParseFiles("templates/main.html")
	tmpl.Execute(w, Homepage{
		Time: fmt.Sprintf("%02d:%02d", time.Now().Hour(), time.Now().Minute()),
		Buttons: []Button{
			{"GitHub", "", "https://github.com/"},
			{"DuckDuckGo", "󰇥", "https://duckduckgo.com/"},
			{"YouTube", "󰗃", "https://youtube.com/"},
			{"Music", "󰝚", "https://music.yandex.ru/"},
		},
		Weather: getWeather(),
	})
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /", handler)

	http.ListenAndServe(":8008", mux)
}
