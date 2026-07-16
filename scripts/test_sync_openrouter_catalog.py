import unittest

from sync_openrouter_catalog import model_ids, model_ids_without_tools, render


class ModelIdsTest(unittest.TestCase):
    def test_orders_newest_first_and_breaks_ties_by_id(self) -> None:
        document = {
            "data": [
                {"id": "zeta/old", "created": 10},
                {"id": "zeta/new", "created": 20},
                {"id": "alpha/new", "created": 20},
            ]
        }

        self.assertEqual(
            model_ids(document),
            ["alpha/new", "zeta/new", "zeta/old"],
        )

    def test_rejects_duplicate_ids(self) -> None:
        document = {
            "data": [
                {"id": "provider/model", "created": 20},
                {"id": "provider/model", "created": 10},
            ]
        }

        with self.assertRaisesRegex(ValueError, "duplicate"):
            model_ids(document)

    def test_rejects_malformed_documents(self) -> None:
        invalid_documents = [
            [],
            {},
            {"data": "not a list"},
            {"data": [None]},
            {"data": [{"id": ""}]},
            {"data": [{"id": "missing-provider"}]},
            {
                "data": [
                    {
                        "id": "provider/model",
                        "supported_parameters": "not a list",
                    }
                ]
            },
        ]

        for document in invalid_documents:
            with self.subTest(document=document):
                with self.assertRaises(ValueError):
                    model_ids(document)

    def test_preserves_models_without_advertised_tools(self) -> None:
        document = {
            "data": [
                {
                    "id": "provider/agent",
                    "created": 20,
                    "supported_parameters": ["tools", "temperature"],
                },
                {
                    "id": "provider/text",
                    "created": 10,
                    "supported_parameters": ["temperature"],
                },
            ]
        }

        self.assertEqual(model_ids_without_tools(document), ["provider/text"])


class RenderTest(unittest.TestCase):
    def test_prefixes_every_model_for_aviary(self) -> None:
        output = render(
            ["sakana/fugu-ultra", "openai/gpt-example"],
            ["openai/gpt-example"],
        )

        self.assertIn('"openrouter/sakana/fugu-ultra"', output)
        self.assertIn('"openrouter/openai/gpt-example"', output)
        self.assertIn("Contains 2 models", output)
        self.assertIn("1 without advertised tool support", output)
        self.assertIn("fun openrouter_models_without_tools()", output)


if __name__ == "__main__":
    unittest.main()
