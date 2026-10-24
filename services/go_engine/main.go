package main
import ("encoding/json";"net";"net/http")
type Iface struct { Name string `json:"name"`; Up bool `json:"up"`; Addrs []string `json:"addrs"` }
func scan() []Iface {
    out := []Iface{}
    ifs, _ := net.Interfaces()
    for _, i := range ifs {
        a, _ := i.Addrs()
        addrs := []string{}
        for _, x := range a { addrs = append(addrs, x.String()) }
        out = append(out, Iface{i.Name, i.Flags&net.FlagUp != 0, addrs})
    }
    return out
}
func main() {
    http.HandleFunc("/interfaces", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(scan())
    })
    http.ListenAndServe(":8081", nil)
}
