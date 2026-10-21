# femboyvpn
api for femboyvpn.connecto.lol Одна подписка для телефона и компьютера. Выберите удобный срок, подключитесь и управляйте доступом в личном кабинете
# main
```swift
import Foundation
import femboyvpn

let femboy = femboyVpn()
let tarifs = try await femboy.getTarifs()
print(tarifs)
```

# Launch (your script)
```
swift run
```
