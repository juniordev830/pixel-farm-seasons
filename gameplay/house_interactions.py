"""House interactions, designed to work independently of the rendering engine."""
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class HomeState:
    room: str = "porch"
    fridge_open: bool = False
    tv_on: bool = False
    shower_running: bool = False
    outfit: str = "farmer"
    inventory: dict[str, int] = field(default_factory=lambda: {"vegetables": 2, "eggs": 2})
    messages: list[str] = field(default_factory=list)

    def enter(self, room: str) -> str:
        allowed = {"porch", "living_room", "kitchen", "bathroom", "bedroom"}
        if room not in allowed:
            raise ValueError("Unknown room")
        self.room = room
        return f"Você entrou em: {room}"

    def interact(self, object_name: str, farmer=None) -> str:
        locations = {
            "fridge": "kitchen", "stove": "kitchen",
            "tv": "living_room", "shower": "bathroom",
            "wardrobe": "bedroom", "bed": "bedroom",
        }
        if object_name not in locations:
            raise ValueError("Unknown interactive object")
        if self.room != locations[object_name]:
            return "Você precisa se aproximar do objeto no cômodo correto."
        if object_name == "fridge":
            self.fridge_open = not self.fridge_open
            return "Geladeira aberta." if self.fridge_open else "Geladeira fechada."
        if object_name == "tv":
            self.tv_on = not self.tv_on
            return "Televisão ligada." if self.tv_on else "Televisão desligada."
        if object_name == "shower":
            self.shower_running = not self.shower_running
            if farmer and self.shower_running:
                farmer.advance(15, "idle")
            return "Banho iniciado." if self.shower_running else "Chuveiro desligado."
        if object_name == "wardrobe":
            self.outfit = "casual" if self.outfit == "farmer" else "farmer"
            return f"Roupa selecionada: {self.outfit}"
        if object_name == "stove":
            if self.inventory.get("vegetables", 0) < 1 or self.inventory.get("eggs", 0) < 1:
                return "Faltam ingredientes para cozinhar."
            self.inventory["vegetables"] -= 1
            self.inventory["eggs"] -= 1
            if farmer:
                farmer.advance(20, "idle")
                farmer.eat(40)
            return "Refeição preparada e consumida."
        if object_name == "bed":
            if farmer is None:
                return "É necessário um personagem para dormir."
            farmer.sleep(8)
            return f"Você dormiu e acordou às {farmer.clock}."
        raise AssertionError("Unreachable")
