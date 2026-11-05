import unittest
from gameplay.daily_needs import Farmer
from gameplay.day_night import lighting_at

class DailyNeedsTests(unittest.TestCase):
    def test_idle_advances_clock(self):
        farmer = Farmer()
        farmer.advance(60)
        self.assertEqual(farmer.clock, "08:00")

    def test_hunger_and_farming_energy(self):
        farmer = Farmer()
        farmer.advance(240, "farming")
        self.assertGreater(farmer.hunger, 0)
        self.assertLess(farmer.energy, 100)

    def test_sleep_restores_energy_and_advances_time(self):
        farmer = Farmer(minute=22*60, energy=20, fatigue=70)
        farmer.sleep(8)
        self.assertEqual(farmer.clock, "06:00")
        self.assertGreater(farmer.energy, 20)
        self.assertLess(farmer.fatigue, 70)

    def test_sky_phases(self):
        self.assertEqual(lighting_at(6*60).phase, "sunrise")
        self.assertEqual(lighting_at(12*60).phase, "day")
        self.assertEqual(lighting_at(18*60).phase, "sunset")
        self.assertEqual(lighting_at(23*60).phase, "night")
        self.assertTrue(lighting_at(23*60).house_lights)

if __name__ == "__main__":
    unittest.main()
