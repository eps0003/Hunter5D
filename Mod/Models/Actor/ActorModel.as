#include "Model.as"

shared class ActorModel : Model
{
	ActorModel(string texture, float scale = 1.0f)
	{
		super(scale);

		ModelSegment@ body = AddSegment("body", "ActorBody.obj", texture);
		ModelSegment@ head = AddSegment("head", "ActorHead.obj", texture);
		ModelSegment@ upperLeftArm = AddSegment("upperLeftArm", "ActorUpperLeftArm.obj", texture);
		ModelSegment@ lowerLeftArm = AddSegment("lowerLeftArm", "ActorLowerLeftArm.obj", texture);
		ModelSegment@ upperRightArm = AddSegment("upperRightArm", "ActorUpperRightArm.obj", texture);
		ModelSegment@ lowerRightArm = AddSegment("lowerRightArm", "ActorLowerRightArm.obj", texture);
		ModelSegment@ upperLeftLeg = AddSegment("upperLeftLeg", "ActorUpperLeftLeg.obj", texture);
		ModelSegment@ lowerLeftLeg = AddSegment("lowerLeftLeg", "ActorLowerLeftLeg.obj", texture);
		ModelSegment@ upperRightLeg = AddSegment("upperRightLeg", "ActorUpperRightLeg.obj", texture);
		ModelSegment@ lowerRightLeg = AddSegment("lowerRightLeg", "ActorLowerRightLeg.obj", texture);

		body.AddChild(head);
		body.AddChild(upperLeftArm);
		body.AddChild(upperRightArm);
		body.AddChild(upperLeftLeg);
		body.AddChild(upperRightLeg);

		upperLeftArm.AddChild(lowerLeftArm);
		upperRightArm.AddChild(lowerRightArm);
		upperLeftLeg.AddChild(lowerLeftLeg);
		upperRightLeg.AddChild(lowerRightLeg);

		body.initialOffset = Vec3f(0, 0.75f, 0);
		head.initialOffset = Vec3f(0, 0.75f, 0);
		upperLeftArm.initialOffset = Vec3f(-0.25f, 0.75f, 0);
		lowerLeftArm.initialOffset = Vec3f(-0.125f, -0.375f, -0.125f);
		upperRightArm.initialOffset = Vec3f(0.25f, 0.75f, 0);
		lowerRightArm.initialOffset = Vec3f(0.125f, -0.375f, -0.125f);
		lowerLeftLeg.initialOffset = Vec3f(-0.125f, -0.375f, 0.125f);
		lowerRightLeg.initialOffset = Vec3f(0.125f, -0.375f, 0.125f);
	}
}
