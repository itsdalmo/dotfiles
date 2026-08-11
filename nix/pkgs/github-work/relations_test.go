package githubwork

import "testing"

func TestExtractRelationsPreservesMeaningAndContext(t *testing.T) {
	item := Item{
		Type: "pr",
		Repo: "AidnAS/toolkit",
		URL:  "https://github.com/AidnAS/toolkit/pull/43",
		Body: "Part of: AidnAS/platform#6688\n\nRefs #42\n\nRelated to #44",
	}
	relations := extractRelations(item)
	if len(relations) != 3 {
		t.Fatalf("got %d relations: %#v", len(relations), relations)
	}
	if relations[0].Kind != "part_of" || relations[0].URL != "https://github.com/AidnAS/platform/issues/6688" {
		t.Fatalf("first relation = %#v", relations[0])
	}
	if relations[1].Kind != "references" || relations[1].URL != "https://github.com/AidnAS/toolkit/issues/42" {
		t.Fatalf("second relation = %#v", relations[1])
	}
	if relations[2].Kind != "related_to" || relations[2].URL != "https://github.com/AidnAS/toolkit/issues/44" {
		t.Fatalf("third relation = %#v", relations[2])
	}
	for _, relation := range relations {
		if relation.Source != "body" || relation.Context == "" {
			t.Fatalf("relation lacks body evidence: %#v", relation)
		}
	}
}

func TestExtractRelationsDoesNotDuplicateFullURLs(t *testing.T) {
	item := Item{Type: "pr", Repo: "AidnAS/example", URL: "self", Body: "Refs https://github.com/AidnAS/other/issues/12 and AidnAS/other#12"}
	relations := extractRelations(item)
	if len(relations) != 1 {
		t.Fatalf("got %d relations: %#v", len(relations), relations)
	}
}

func TestExtractRelationsRecognizesOnlyExplicitPRBodyLines(t *testing.T) {
	item := Item{Type: "pr", Repo: "AidnAS/example", URL: "self", Body: `This description mentions #1 incidentally.
Depends on #2
- Ref #3
Closes: #4
Fixes #5 and #6
Resolves AidnAS/other#7`}
	relations := extractRelations(item)
	if len(relations) != 4 {
		t.Fatalf("got %d relations, want four: %#v", len(relations), relations)
	}
	for index, want := range []string{
		"https://github.com/AidnAS/example/issues/4",
		"https://github.com/AidnAS/example/issues/5",
		"https://github.com/AidnAS/example/issues/6",
		"https://github.com/AidnAS/other/issues/7",
	} {
		if relations[index].URL != want || relations[index].Kind != "closes" {
			t.Fatalf("relation %d = %#v", index, relations[index])
		}
	}
}

func TestExtractRelationsIgnoresIssueBodies(t *testing.T) {
	item := Item{Type: "issue", Repo: "AidnAS/example", Body: "Part of #12"}
	if relations := extractRelations(item); len(relations) != 0 {
		t.Fatalf("relations = %#v", relations)
	}
}

func TestExtractRelationsIgnoresCaseAndAllowsFlexibleWhitespaceAndColon(t *testing.T) {
	item := Item{Type: "pr", Repo: "AidnAS/example", Body: "  FIXES:#1\n\tPart   Of :  #2\nReF\t#3\nFixesfoo #4"}
	relations := extractRelations(item)
	if len(relations) != 3 {
		t.Fatalf("got %d relations, want three: %#v", len(relations), relations)
	}
	for index, want := range []string{
		"https://github.com/AidnAS/example/issues/1",
		"https://github.com/AidnAS/example/issues/2",
		"https://github.com/AidnAS/example/issues/3",
	} {
		if relations[index].URL != want {
			t.Fatalf("relation %d = %#v", index, relations[index])
		}
	}
}
