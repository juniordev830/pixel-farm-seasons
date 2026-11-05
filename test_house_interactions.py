import unittest

from gameplay.daily_needs import Farmer
from gameplay.house_interactions import HomeState


class HomeInteractionsTests(unittest.TestCase):
    def test_cooking_requires_character_without_wasting_food(self):
        home = HomeState()
        home.enter("kitchen")
        before = home.inventory.copy()

        self.assertIn("necessário", home.interact("stove"))
        self.assertEqual(home.inventory, before)

    def test_cooking_consumes_one_recipe_advances_time_and_reduces_hunger(self):
        home = HomeState()
        home.enter("kitchen")
        farmer = Farmer(minute=11 * 60, hunger=80.0, energy=50.0)
        before = home.inventory.copy()

        self.assertEqual(home.interact("stove", farmer), "Refeição preparada e consumida.")
        self.assertEqual(farmer.clock, "11:20")
        self.assertEqual(farmer.last_meal, 11 * 60 + 20)
        self.assertLess(farmer.hunger, 80.0)
        self.assertGreater(farmer.energy, 50.0)
        self.assertEqual(home.inventory["vegetables"], before["vegetables"] - 1)
        self.assertEqual(home.inventory["eggs"], before["eggs"] - 1)

    def test_cannot_cook_without_ingredients_or_from_another_room(self):
        home = HomeState()
        farmer = Farmer(minute=11 * 60, hunger=80.0)
        self.assertIn("cômodo correto", home.interact("stove", farmer))
        self.assertEqual(farmer.clock, "11:00")

        home.enter("kitchen")
        home.inventory["eggs"] = 0
        before = home.inventory.copy()
        self.assertIn("Faltam ingredientes", home.interact("stove", farmer))
        self.assertEqual(home.inventory, before)
        self.assertEqual(farmer.clock, "11:00")

    def test_bed_remains_optional_and_sleep_advances_world_clock(self):
        home = HomeState()
        home.enter("bedroom")
        farmer = Farmer(minute=23 * 60, energy=15.0, fatigue=95.0)
        self.assertIn("07:00", home.interact("bed", farmer))
        self.assertEqual(farmer.clock, "07:00")
        self.assertGreater(farmer.energy, 15.0)

    def test_refrigerator_toggles_without_affecting_inventory(self):
        home = HomeState()
        home.enter("kitchen")
        before = home.inventory.copy()
        self.assertEqual(home.interact("fridge"), "Geladeira aberta.")
        self.assertTrue(home.fridge_open)
        self.assertEqual(home.interact("fridge"), "Geladeira fechada.")
        self.assertFalse(home.fridge_open)
        self.assertEqual(home.inventory, before)


if __name__ == "__main__":
    unittest.main()
