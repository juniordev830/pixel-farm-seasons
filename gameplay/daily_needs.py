"""Engine-independent daily needs and sleep rules."""
from dataclasses import dataclass

@dataclass
class Farmer:
    minute: int = 7 * 60
    energy: float = 100.0
    hunger: float = 0.0
    last_meal: int = 7 * 60
    fatigue: float = 0.0
    last_wake: int = 7 * 60

    @property
    def clock(self) -> str:
        return f"{(self.minute // 60) % 24:02d}:{self.minute % 60:02d}"

    def advance(self, minutes: int, activity: str = "idle") -> list[str]:
        if minutes < 0:
            raise ValueError("minutes must be non-negative")
        drains = {"idle": 0.005, "walking": 0.025, "farming": 0.06}
        if activity not in drains:
            raise ValueError(f"unknown activity: {activity}")
        events = []
        for _ in range(minutes):
            self.minute += 1
            hour = (self.minute // 60) % 24
            self.hunger = min(100.0, self.hunger + 0.045)
            self.fatigue = min(100.0, self.fatigue + (0.075 if activity == "farming" else 0.055))
            drain = drains[activity] + (0.035 if self.hunger >= 65 else 0)
            if self.minute - self.last_wake >= 17 * 60:
                drain += 0.055
            self.energy = max(0.0, self.energy - drain)
            if self.minute % 60 == 0 and self.hunger >= 65:
                events.append("Estou com fome! Preciso comer alguma coisa.")
            if hour == 11 and self.minute % 60 == 0 and self.minute - self.last_meal >= 180:
                events.append("Eita, já são 11 horas! Tenho que pensar no almoço.")
            if hour == 20 and self.minute % 60 == 0:
                events.append("O dia foi puxado. Já estou ficando cansado.")
            if hour == 22 and self.minute % 60 == 0:
                events.append("Está ficando tarde. Preciso descansar.")
            if hour == 0 and self.minute % 60 == 0:
                events.append("Já passou da meia-noite! Amanhã vou sentir esse cansaço.")
        return events

    def eat(self, nutrition: float = 55.0) -> None:
        self.hunger = max(0.0, self.hunger - max(0.0, nutrition))
        self.energy = min(100.0, self.energy + 8.0)
        self.last_meal = self.minute

    def sleep(self, hours: int = 8) -> list[str]:
        if hours <= 0 or hours > 24:
            raise ValueError("sleep duration must be between 1 and 24 hours")
        # Sleep advances the world clock without applying awake activity costs.
        self.minute += hours * 60
        self.hunger = min(100.0, self.hunger + hours * 1.5)
        self.energy = min(100.0, self.energy + hours * 11.0)
        self.fatigue = max(0.0, self.fatigue - hours * 13.0)
        self.last_wake = self.minute
        return ["Bom dia! Hora de cuidar da fazenda."]
